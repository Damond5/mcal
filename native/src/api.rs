use chrono::{NaiveDate, NaiveTime};
use git2::{Delta, Repository};
use rcal_lib::core::EventService;
use rcal_lib::models::{CalendarEvent, Recurrence};
use rcal_lib::storage::FileEventRepository;
use rcal_lib::validation::{is_valid_date_range, is_valid_time_range, is_valid_title};
use std::fs;
use std::path::{Path, PathBuf};
use std::process::Command;
use x509_parser::prelude::*;

#[flutter_rust_bridge::frb]
#[derive(Debug)]
pub struct StatusEntry {
    pub path: String,
    pub status: String,
}

#[flutter_rust_bridge::frb]
#[derive(Debug)]
pub enum GitError {
    Io(String),
    Git(String),
    Auth(String),
    Other(String),
}

impl From<std::io::Error> for GitError {
    fn from(err: std::io::Error) -> Self {
        GitError::Io(err.to_string())
    }
}

impl From<git2::Error> for GitError {
    fn from(err: git2::Error) -> Self {
        GitError::Git(err.to_string())
    }
}

// ============================================================================
// Event DTO for Flutter Rust Bridge
// ============================================================================

#[flutter_rust_bridge::frb]
#[derive(Debug, Clone)]
pub struct EventDto {
    pub id: String,
    pub title: String,
    pub description: String,
    pub start_date: String,
    pub end_date: Option<String>,
    pub start_time: Option<String>,
    pub end_time: Option<String>,
    pub is_all_day: bool,
    pub recurrence: String,
    pub is_recurring_instance: bool,
}

/// Converts a CalendarEvent to an EventDto
fn event_to_dto(event: &CalendarEvent) -> EventDto {
    EventDto {
        id: event.id.clone(),
        title: event.title.clone(),
        description: event.description.clone(),
        start_date: event.start_date.format("%Y-%m-%d").to_string(),
        end_date: event.end_date.map(|d| d.format("%Y-%m-%d").to_string()),
        start_time: if event.is_all_day {
            None
        } else {
            Some(event.start_time.format("%H:%M").to_string())
        },
        end_time: event.end_time.map(|t| t.format("%H:%M").to_string()),
        is_all_day: event.is_all_day,
        recurrence: event.recurrence.to_storage_string().to_string(),
        is_recurring_instance: event.is_recurring_instance,
    }
}

/// Parses a date string in YYYY-MM-DD format
fn parse_date(date_str: &str) -> Result<NaiveDate, String> {
    NaiveDate::parse_from_str(date_str, "%Y-%m-%d")
        .map_err(|e| format!("Invalid date format '{}': {}", date_str, e))
}

/// Parses a time string in HH:MM format
fn parse_time(time_str: &str) -> Result<NaiveTime, String> {
    NaiveTime::parse_from_str(time_str, "%H:%M")
        .map_err(|e| format!("Invalid time format '{}': {}", time_str, e))
}

/// Parses a recurrence string to Recurrence enum
fn parse_recurrence(recurrence: &str) -> Recurrence {
    Recurrence::from_storage_string(recurrence)
}

/// Checks if an event occurs within a date range (inclusive)
fn event_occurs_in_range(event: &CalendarEvent, start: NaiveDate, end: NaiveDate) -> bool {
    // For recurring events, check if any instance falls in range
    if event.recurrence != Recurrence::None {
        // Check if the base event is in range
        if event.start_date >= start && event.start_date <= end {
            return true;
        }
        // Generate a few instances to check (simple check for start date + 1 year)
        let instances = FileEventRepository::generate_recurring_instances(event, end);
        for instance in instances {
            if instance.start_date >= start && instance.start_date <= end {
                return true;
            }
        }
        false
    } else {
        // For non-recurring events, check if the event's date range overlaps
        let event_end = event.effective_end_date();
        event_end >= start && event.start_date <= end
    }
}

/// Creates a CalendarEvent from the input parameters
fn create_calendar_event(
    title: String,
    description: String,
    start_date: String,
    end_date: Option<String>,
    start_time: Option<String>,
    end_time: Option<String>,
    is_all_day: bool,
    recurrence: String,
    existing_id: Option<String>,
) -> Result<CalendarEvent, String> {
    let start = parse_date(&start_date)?;
    // If end_date is provided but equals start_date, treat it as None (no end date specified)
    let end = match end_date {
        Some(ref d) if d == &start_date => None,
        _ => end_date.map(|d| parse_date(&d)).transpose()?,
    };

    let start_t = if is_all_day {
        NaiveTime::from_hms_opt(0, 0, 0).unwrap()
    } else {
        match start_time {
            Some(t) => parse_time(&t)?,
            None => return Err("Start time is required for non-all-day events".to_string()),
        }
    };

    let end_t = if is_all_day {
        None
    } else {
        match end_time {
            Some(t) => Some(parse_time(&t)?),
            None => None,
        }
    };

    let recurrence_enum = parse_recurrence(&recurrence);

    Ok(CalendarEvent {
        id: existing_id.unwrap_or_else(|| uuid::Uuid::new_v4().to_string()),
        title,
        description,
        start_date: start,
        end_date: end,
        start_time: start_t,
        end_time: end_t,
        is_all_day,
        recurrence: recurrence_enum,
        is_recurring_instance: false,
        base_date: None,
    })
}

// Helper function for credentials
fn get_credentials(
    url: &str,
    username: &Option<String>,
    password: &Option<String>,
    ssh_key_path: &Option<String>,
) -> Result<git2::Cred, git2::Error> {
    if url.starts_with("http") || url.starts_with("https") {
        if let (Some(user), Some(pass)) = (username, password) {
            git2::Cred::userpass_plaintext(user, pass)
        } else {
            Err(git2::Error::from_str("Credentials required for HTTPS"))
        }
    } else {
        if let Some(key_path) = ssh_key_path {
            git2::Cred::ssh_key("git", None, Path::new(key_path), None)
        } else {
            git2::Cred::ssh_key_from_agent("git")
        }
    }
}

// Helper function to extract branch name from repo or remote default
pub(crate) fn extract_branch_name(_repo: &Repository) -> String {
    "main".to_string()
}

// Helper function for certificate validation
fn validate_certificate(hostname: &str, cert_data: &[u8]) -> Result<(), String> {
    // Check hostname using x509-parser
    let (_, cert) = x509_parser::parse_x509_certificate(cert_data)
        .map_err(|e| format!("Failed to parse certificate for hostname check: {}", e))?;
    let sans = cert.subject_alternative_name();
    if let Ok(Some(sans)) = sans {
        for san in &sans.value.general_names {
            if let GeneralName::DNSName(dns) = san {
                if *dns == hostname {
                    return Ok(());
                }
            }
        }
    }
    // Also check common name
    if let Some(cn) = cert.subject().iter_common_name().next() {
        if let Ok(cn_str) = cn.as_str() {
            if cn_str == hostname {
                return Ok(());
            }
        }
    }
    Err(format!(
        "Hostname '{}' does not match certificate",
        hostname
    ))
}

// Define the API struct
#[flutter_rust_bridge::frb(init)]
pub fn init_app() {
    // Default utilities - feel free to customize
    flutter_rust_bridge::setup_default_user_utils();
}

// Placeholder for Git operations
#[flutter_rust_bridge::frb]
pub fn add(left: i32, right: i32) -> i32 {
    left + right
}

// Git operations
fn git_init_impl(path: String) -> Result<String, GitError> {
    Repository::init(&path)?;
    Ok("Initialized empty Git repository".to_string())
}

#[flutter_rust_bridge::frb]
pub fn git_init(path: String) -> Result<String, GitError> {
    git_init_impl(path)
}

#[flutter_rust_bridge::frb]
pub fn git_clone(
    url: String,
    path: String,
    username: Option<String>,
    password: Option<String>,
    ssh_key_path: Option<String>,
) -> Result<String, GitError> {
    let mut callbacks = git2::RemoteCallbacks::new();
    let username = username.clone();
    let password = password.clone();
    let ssh_key_path = ssh_key_path.clone();
    let _url_clone = url.clone();
    callbacks
        .credentials(move |url, _, _| get_credentials(url, &username, &password, &ssh_key_path));
    callbacks.certificate_check(move |cert, hostname| {
        if let Some(x509) = cert.as_x509() {
            match validate_certificate(hostname, x509.data()) {
                Ok(()) => Ok(git2::CertificateCheckStatus::CertificateOk),
                Err(e) => Err(git2::Error::from_str(&e)),
            }
        } else {
            Ok(git2::CertificateCheckStatus::CertificateOk)
        }
    });
    let mut fetch_options = git2::FetchOptions::new();
    fetch_options.remote_callbacks(callbacks);
    let mut builder = git2::build::RepoBuilder::new();
    builder.fetch_options(fetch_options);
    builder.clone(&url, Path::new(&path))?;
    Ok("Repository cloned successfully".to_string())
}

#[flutter_rust_bridge::frb]
pub fn git_current_branch(path: String) -> Result<String, GitError> {
    let repo = Repository::open(&path)?;
    let head_ref = repo.head()?;
    let branch_name = head_ref
        .name()
        .and_then(|n| n.strip_prefix("refs/heads/"))
        .unwrap_or("unknown");
    Ok(branch_name.to_string())
}

#[flutter_rust_bridge::frb]
pub fn git_list_branches(path: String) -> Result<Vec<String>, GitError> {
    let repo = Repository::open(&path)?;
    let branches = repo.branches(None)?;
    let mut branch_names = Vec::new();
    for branch_result in branches {
        let (branch, _) = branch_result?;
        if let Some(name) = branch.name()? {
            branch_names.push(name.to_string());
        }
    }
    Ok(branch_names)
}

// Helper function to check if there are local uncommitted changes
fn has_local_changes(repo: &Repository) -> Result<bool, GitError> {
    let statuses = repo.statuses(None)?;
    Ok(statuses.iter().any(|entry| {
        let status = entry.status();
        status.contains(git2::Status::WT_MODIFIED)
            || status.contains(git2::Status::WT_DELETED)
            || status.contains(git2::Status::WT_NEW)
            || status.contains(git2::Status::INDEX_MODIFIED)
            || status.contains(git2::Status::INDEX_DELETED)
            || status.contains(git2::Status::INDEX_NEW)
    }))
}

#[flutter_rust_bridge::frb]
pub fn git_has_local_changes(path: String) -> Result<bool, GitError> {
    let repo = Repository::open(&path)?;
    has_local_changes(&repo)
}

/// Pull from remote repository, handling local uncommitted changes by stashing them.
/// If pull succeeds, attempts to restore stashed changes.
/// If stash pop fails due to conflicts, drops the stash to prefer remote changes.
fn git_pull_impl(
    path: String,
    username: Option<String>,
    password: Option<String>,
    ssh_key_path: Option<String>,
) -> Result<String, GitError> {
    let mut repo = Repository::open(&path)?;
    let has_changes = has_local_changes(&repo)?;
    let mut stashed = false;
    let old_tree = repo.head()?.peel_to_tree()?;
    let old_oid = old_tree.id();
    drop(old_tree);
    let mut new_tree: Option<git2::Tree> = None;

    // Stash local changes to allow pull to update working directory
    // Handle gracefully - if stash fails (e.g., "nothing to stash"), just proceed without stashing
    if has_changes {
        let signature = git2::Signature::now("App", "app@example.com")?;
        match repo.stash_save(&signature, "Stashed by app during pull", None) {
            Ok(_) => {
                stashed = true;
            }
            Err(_) => {
                // Don't error out - just proceed without stashing
                stashed = false;
            }
        }
    }

    let result = (|| {
        let branch_name = extract_branch_name(&repo);
        let mut remote = repo.find_remote("origin")?;
        let mut callbacks = git2::RemoteCallbacks::new();
        let username = username.clone();
        let password = password.clone();
        let ssh_key_path = ssh_key_path.clone();
        callbacks.credentials(move |url, _, _| {
            get_credentials(url, &username, &password, &ssh_key_path)
        });
        callbacks.certificate_check(move |cert, hostname| {
            if let Some(x509) = cert.as_x509() {
                match validate_certificate(hostname, x509.data()) {
                    Ok(()) => Ok(git2::CertificateCheckStatus::CertificateOk),
                    Err(e) => Err(git2::Error::from_str(&e)),
                }
            } else {
                Ok(git2::CertificateCheckStatus::CertificateOk)
            }
        });
        let mut fetch_options = git2::FetchOptions::new();
        fetch_options.remote_callbacks(callbacks);
        remote.fetch(&[branch_name.as_str()], Some(&mut fetch_options), None)?;
        let fetch_head = repo.find_reference("FETCH_HEAD")?;
        let fetch_commit = repo.reference_to_annotated_commit(&fetch_head)?;
        let analysis = repo.merge_analysis(&[&fetch_commit])?;
        if analysis.0.is_up_to_date() {
            // Checkout HEAD to ensure working directory matches HEAD
            repo.checkout_head(None)?;

            Ok("Already up to date".to_string())
        } else if analysis.0.is_fast_forward() {
            let refname = format!("refs/heads/{}", branch_name);
            let mut reference = if let Ok(r) = repo.find_reference(&refname) {
                r
            } else {
                repo.reference(&refname, fetch_commit.id(), true, "Creating branch")?
            };
            reference.set_target(fetch_commit.id(), "Fast-forward")?;
            repo.set_head(&refname)?;
            repo.checkout_head(None)?;
            new_tree = Some(repo.head()?.peel_to_tree()?);
            Ok("Fast-forward merge completed".to_string())
        } else {
            Err(GitError::Other(
                "Non-fast-forward merge required".to_string(),
            ))
        }
    })();

    // Analyze the diff to see what changed
    #[allow(unused_variables)]
    let (deleted_paths, added_paths, modified_paths): (Vec<String>, Vec<String>, Vec<String>) =
        if result.is_ok() {
            if let Some(new_tree) = &new_tree {
                let old_tree = repo.find_tree(old_oid).ok();
                let diff = if let Some(ref old) = old_tree {
                    repo.diff_tree_to_tree(Some(old), Some(new_tree), None)
                } else {
                    // If old tree not available, diff against HEAD
                    repo.diff_tree_to_tree(None, Some(new_tree), None)
                }
                .ok();

                if let Some(diff) = diff {
                    let deleted: Vec<String> = diff
                        .deltas()
                        .filter(|d| d.status() == Delta::Deleted)
                        .map(|d| {
                            d.old_file().path().map_or_else(
                                || "<unknown>".to_string(),
                                |p| p.to_string_lossy().to_string(),
                            )
                        })
                        .collect();
                    let added: Vec<String> = diff
                        .deltas()
                        .filter(|d| d.status() == Delta::Added)
                        .map(|d| {
                            d.new_file().path().map_or_else(
                                || "<unknown>".to_string(),
                                |p| p.to_string_lossy().to_string(),
                            )
                        })
                        .collect();
                    let modified: Vec<String> = diff
                        .deltas()
                        .filter(|d| d.status() == Delta::Modified)
                        .map(|d| {
                            d.old_file().path().map_or_else(
                                || "<unknown>".to_string(),
                                |p| p.to_string_lossy().to_string(),
                            )
                        })
                        .collect();

                    (deleted, added, modified)
                } else {
                    (vec![], vec![], vec![])
                }
            } else {
                (vec![], vec![], vec![])
            }
        } else {
            (vec![], vec![], vec![])
        };

    drop(new_tree);

    // Handle stash after pull operation
    if stashed {
        if result.is_ok() {
            // Pull succeeded: DON'T restore stash - we want remote (HEAD) to win
            // The checkout_head() already gave us the correct files from remote
            // Drop any stashed changes to avoid conflicts
            let _ = repo.stash_drop(0);
        } else {
            // Pull failed: restore local changes via stash_pop
            if let Err(_) = repo.stash_pop(0, None) {
                let _ = repo.stash_drop(0);
            }
        }
    }

    // Handle deletion of files that were deleted in remote
    // This must happen outside the stash block to ensure deletions are processed
    // even when there were no local changes to stash
    if result.is_ok() {
        for path in deleted_paths {
            if let Some(workdir) = repo.workdir() {
                let full_path = workdir.join(&path);
                if full_path.exists() {
                    let _ = fs::remove_file(&full_path);
                }
            }
        }
    }

    result
}

#[flutter_rust_bridge::frb]
pub fn git_pull(
    path: String,
    username: Option<String>,
    password: Option<String>,
    ssh_key_path: Option<String>,
) -> Result<String, GitError> {
    git_pull_impl(path, username, password, ssh_key_path)
}

fn git_push_impl(
    path: String,
    username: Option<String>,
    password: Option<String>,
    ssh_key_path: Option<String>,
) -> Result<String, GitError> {
    let repo = Repository::open(&path)?;
    let branch_name = extract_branch_name(&repo);
    let mut remote = repo.find_remote("origin")?;
    let mut callbacks = git2::RemoteCallbacks::new();
    let username = username.clone();
    let password = password.clone();
    let ssh_key_path = ssh_key_path.clone();
    callbacks
        .credentials(move |url, _, _| get_credentials(url, &username, &password, &ssh_key_path));
    callbacks.certificate_check(move |cert, hostname| {
        if let Some(x509) = cert.as_x509() {
            match validate_certificate(hostname, x509.data()) {
                Ok(()) => Ok(git2::CertificateCheckStatus::CertificateOk),
                Err(e) => Err(git2::Error::from_str(&e)),
            }
        } else {
            Ok(git2::CertificateCheckStatus::CertificateOk)
        }
    });
    let mut push_options = git2::PushOptions::new();
    push_options.remote_callbacks(callbacks);
    let refspec = format!("refs/heads/{}", branch_name);
    remote.push(&[refspec.as_str()], Some(&mut push_options))?;
    Ok("Pushed successfully".to_string())
}

#[flutter_rust_bridge::frb]
pub fn git_push(
    path: String,
    username: Option<String>,
    password: Option<String>,
    ssh_key_path: Option<String>,
) -> Result<String, GitError> {
    git_push_impl(path, username, password, ssh_key_path)
}

fn git_status_impl(path: String) -> Result<Vec<StatusEntry>, GitError> {
    let repo = Repository::open(&path)?;
    let statuses = repo.statuses(None)?;
    let mut entries = Vec::new();
    for entry in statuses.iter() {
        let path = entry.path().unwrap_or("unknown");
        let status = format!("{:?}", entry.status());
        entries.push(StatusEntry {
            path: path.to_string(),
            status,
        });
    }
    Ok(entries)
}

#[flutter_rust_bridge::frb]
pub fn git_status(path: String) -> Result<Vec<StatusEntry>, GitError> {
    git_status_impl(path)
}
fn git_add_remote_impl(path: String, name: String, url: String) -> Result<String, GitError> {
    let repo = Repository::open(&path)?;
    repo.remote(&name, &url)?;
    Ok("Remote added".to_string())
}

#[flutter_rust_bridge::frb]
pub fn git_add_remote(path: String, name: String, url: String) -> Result<String, GitError> {
    git_add_remote_impl(path, name, url)
}

fn git_remove_remote_impl(path: String, name: String) -> Result<String, GitError> {
    let repo = Repository::open(&path)?;
    repo.remote_delete(&name)?;
    Ok("Remote removed".to_string())
}

#[flutter_rust_bridge::frb]
pub fn git_remove_remote(path: String, name: String) -> Result<String, GitError> {
    git_remove_remote_impl(path, name)
}

fn git_fetch_impl(
    path: String,
    remote: String,
    username: Option<String>,
    password: Option<String>,
    ssh_key_path: Option<String>,
) -> Result<String, GitError> {
    let repo = Repository::open(&path)?;
    let branch_name = extract_branch_name(&repo);
    let mut remote_obj = repo.find_remote(&remote)?;
    let mut callbacks = git2::RemoteCallbacks::new();
    let username = username.clone();
    let password = password.clone();
    let ssh_key_path = ssh_key_path.clone();
    callbacks
        .credentials(move |url, _, _| get_credentials(url, &username, &password, &ssh_key_path));
    callbacks.certificate_check(move |cert, hostname| {
        if let Some(x509) = cert.as_x509() {
            match validate_certificate(hostname, x509.data()) {
                Ok(()) => Ok(git2::CertificateCheckStatus::CertificateOk),
                Err(e) => Err(git2::Error::from_str(&e)),
            }
        } else {
            Ok(git2::CertificateCheckStatus::CertificateOk)
        }
    });
    let mut fetch_options = git2::FetchOptions::new();
    fetch_options.remote_callbacks(callbacks);
    remote_obj.fetch(&[branch_name.as_str()], Some(&mut fetch_options), None)?;
    Ok("Fetched".to_string())
}

#[flutter_rust_bridge::frb]
pub fn git_fetch(
    path: String,
    remote: String,
    username: Option<String>,
    password: Option<String>,
    ssh_key_path: Option<String>,
) -> Result<String, GitError> {
    git_fetch_impl(path, remote, username, password, ssh_key_path)
}

fn git_checkout_impl(path: String, branch: String) -> Result<String, GitError> {
    let repo = Repository::open(&path)?;
    let head_ref_name = format!("refs/heads/{}", branch);
    if repo.find_reference(&head_ref_name).is_ok() {
        // Branch exists, just set head and checkout
        repo.set_head(&head_ref_name)?;
        repo.checkout_head(None)?;
    } else {
        // Create branch from FETCH_HEAD
        let fetch_head = repo.find_reference("FETCH_HEAD")?;
        let commit = repo.find_commit(fetch_head.target().unwrap())?;
        repo.branch(&branch, &commit, false)?;
        repo.set_head(&head_ref_name)?;
        repo.checkout_head(None)?;
    }
    Ok("Checked out".to_string())
}

#[flutter_rust_bridge::frb]
pub fn git_checkout(path: String, branch: String) -> Result<String, GitError> {
    git_checkout_impl(path, branch)
}

fn git_add_all_impl(path: String) -> Result<String, GitError> {
    let repo = Repository::open(&path)?;
    let mut index = repo.index()?;
    index.add_all(["*"].iter(), git2::IndexAddOption::DEFAULT, None)?;
    index.write()?;
    Ok("Added all".to_string())
}

#[flutter_rust_bridge::frb]
pub fn git_add_all(path: String) -> Result<String, GitError> {
    git_add_all_impl(path)
}

fn git_commit_impl(path: String, message: String) -> Result<String, GitError> {
    let repo = Repository::open(&path)?;
    let mut index = repo.index()?;
    let oid = index.write_tree()?;
    let tree = repo.find_tree(oid)?;
    let signature = git2::Signature::now("App", "app@example.com")?;
    let parent_commit = repo
        .head()
        .ok()
        .and_then(|head| head.target())
        .and_then(|oid| repo.find_commit(oid).ok());
    let commit = if let Some(parent) = parent_commit {
        repo.commit(
            Some("HEAD"),
            &signature,
            &signature,
            &message,
            &tree,
            &[&parent],
        )?
    } else {
        repo.commit(Some("HEAD"), &signature, &signature, &message, &tree, &[])?
    };
    Ok(commit.to_string())
}

#[flutter_rust_bridge::frb]
pub fn git_commit(path: String, message: String) -> Result<String, GitError> {
    git_commit_impl(path, message)
}

// Note: Using git commands for merge resolution as git2 does not provide a simple API for preferring remote changes in conflicts.
// git2's merge and conflict resolution require manual iteration and resolution, which is complex for this use case.
// Keeping command-based for reliability and simplicity.
fn git_merge_prefer_remote_impl(path: String) -> Result<String, GitError> {
    let output = Command::new("git")
        .arg("checkout")
        .arg("--theirs")
        .arg(".")
        .current_dir(&path)
        .output()?;
    if !output.status.success() {
        return Err(GitError::Other(
            String::from_utf8_lossy(&output.stderr).to_string(),
        ));
    }
    let output = Command::new("git")
        .arg("add")
        .arg(".")
        .current_dir(&path)
        .output()?;
    if !output.status.success() {
        return Err(GitError::Other(
            String::from_utf8_lossy(&output.stderr).to_string(),
        ));
    }
    let output = Command::new("git")
        .arg("commit")
        .arg("-m")
        .arg("Merge resolved by preferring remote")
        .current_dir(&path)
        .output()?;
    if !output.status.success() {
        return Err(GitError::Other(
            String::from_utf8_lossy(&output.stderr).to_string(),
        ));
    }
    Ok("Merge resolved by preferring remote".to_string())
}

#[flutter_rust_bridge::frb]
pub fn git_merge_prefer_remote(path: String) -> Result<String, GitError> {
    git_merge_prefer_remote_impl(path)
}

#[flutter_rust_bridge::frb]
pub fn git_merge_abort(path: String) -> Result<String, GitError> {
    git_merge_abort_impl(path)
}

fn git_stash_impl(path: String) -> Result<String, GitError> {
    let mut repo = Repository::open(&path)?;
    let signature = git2::Signature::now("App", "app@example.com")?;
    repo.stash_save(&signature, "Stashed by app", None)?;
    Ok("Stashed".to_string())
}

#[flutter_rust_bridge::frb]
pub fn git_stash(path: String) -> Result<String, GitError> {
    git_stash_impl(path)
}

fn git_diff_impl(path: String) -> Result<String, GitError> {
    let repo = Repository::open(&path)?;
    let head = repo.head()?;
    let head_tree = head.peel_to_tree()?;
    let diff = repo.diff_tree_to_workdir(Some(&head_tree), None)?;
    let mut diff_str = String::new();
    diff.print(git2::DiffFormat::Patch, |delta, _hunk, line| {
        diff_str.push_str(&format!(
            "{:?} {:?} {:?}\n",
            delta.old_file().path(),
            delta.new_file().path(),
            line.origin()
        ));
        true
    })?;
    Ok(diff_str)
}

#[flutter_rust_bridge::frb]
pub fn git_diff(path: String) -> Result<String, GitError> {
    git_diff_impl(path)
}

// Note: Using git command for merge abort as git2 does not have a direct equivalent.
// git merge --abort safely resets the repository to pre-merge state, handling conflicts and staged changes.
// git2's reset may not fully replicate this behavior in all cases.
fn git_merge_abort_impl(path: String) -> Result<String, GitError> {
    let output = Command::new("git")
        .arg("merge")
        .arg("--abort")
        .current_dir(&path)
        .output()?;
    if !output.status.success() {
        return Err(GitError::Other(
            String::from_utf8_lossy(&output.stderr).to_string(),
        ));
    }
    Ok("Merge aborted".to_string())
}

#[flutter_rust_bridge::frb]
pub fn set_ssl_ca_certs(pem_certs: Vec<String>) -> Result<(), GitError> {
    let mut temp_file = tempfile::NamedTempFile::new()?;
    for cert in pem_certs {
        std::io::Write::write_all(&mut temp_file, cert.as_bytes())?;
    }
    let path = temp_file.path().to_str().unwrap();
    // Set GIT_SSL_CAINFO environment variable for libgit2
    std::env::set_var("GIT_SSL_CAINFO", path);
    // Keep temp_file alive until process ends
    std::mem::forget(temp_file);
    Ok(())
}

// ============================================================================
// Calendar Event Functions (rcal-lib wrapper)
// ============================================================================

/// Creates a new calendar event and saves it to the specified calendar directory.
#[flutter_rust_bridge::frb]
pub fn create_event(
    title: String,
    description: String,
    start_date: String,
    end_date: Option<String>,
    start_time: Option<String>,
    end_time: Option<String>,
    is_all_day: bool,
    recurrence: String,
    calendar_dir: String,
) -> Result<String, String> {
    let event = create_calendar_event(
        title,
        description,
        start_date,
        end_date,
        start_time,
        end_time,
        is_all_day,
        recurrence,
        None,
    )?;

    let path = PathBuf::from(&calendar_dir);
    let repo = FileEventRepository::with_path(path.clone());
    repo.save_to_path(&event, &path)
        .map_err(|e| e.to_string())?;

    Ok(event.id)
}

/// Gets all events from the specified calendar directory.
#[flutter_rust_bridge::frb]
pub fn get_all_events(calendar_dir: String) -> Result<Vec<EventDto>, String> {
    let path = PathBuf::from(&calendar_dir);
    let repo = FileEventRepository::with_path(path.clone());
    let events = repo.load_from_path(&path).map_err(|e| e.to_string())?;

    // Filter out recurring instances - only return base events
    let base_events: Vec<&CalendarEvent> =
        events.iter().filter(|e| !e.is_recurring_instance).collect();

    Ok(base_events.iter().map(|e| event_to_dto(e)).collect())
}

/// Gets all events within a date range from the specified calendar directory.
#[flutter_rust_bridge::frb]
pub fn get_events_in_range(
    start_date: String,
    end_date: String,
    calendar_dir: String,
) -> Result<Vec<EventDto>, String> {
    let start = parse_date(&start_date)?;
    let end = parse_date(&end_date)?;

    let path = PathBuf::from(&calendar_dir);
    let repo = FileEventRepository::with_path(path.clone());
    let events = repo.load_from_path(&path).map_err(|e| e.to_string())?;

    // Filter events that occur within the date range and are not recurring instances
    let filtered: Vec<&CalendarEvent> = events
        .iter()
        .filter(|e| !e.is_recurring_instance && event_occurs_in_range(e, start, end))
        .collect();

    Ok(filtered.iter().map(|e| event_to_dto(e)).collect())
}

/// Updates an existing event in the specified calendar directory.
#[flutter_rust_bridge::frb]
pub fn update_event(
    id: String,
    title: String,
    description: String,
    start_date: String,
    end_date: Option<String>,
    start_time: Option<String>,
    end_time: Option<String>,
    is_all_day: bool,
    recurrence: String,
    calendar_dir: String,
) -> Result<(), String> {
    let path = PathBuf::from(&calendar_dir);
    let repo = FileEventRepository::with_path(path.clone());

    // Verify the event exists by loading and checking
    let events = repo
        .load_from_path(&path)
        .map_err(|e: Box<dyn std::error::Error>| e.to_string())?;
    let existing_event = events
        .iter()
        .find(|e| e.id == id)
        .ok_or_else(|| format!("Event with id '{}' not found", id))?;

    // Create updated event with the same ID
    let updated_event = create_calendar_event(
        title,
        description,
        start_date,
        end_date,
        start_time,
        end_time,
        is_all_day,
        recurrence,
        Some(id.clone()),
    )?;

    // Delete the old event file by title and save the new one
    repo.delete_by_title_from_path(&existing_event.title, &path)
        .map_err(|e: Box<dyn std::error::Error>| e.to_string())?;
    repo.save_to_path(&updated_event, &path)
        .map_err(|e| e.to_string())?;

    Ok(())
}

/// Deletes an event from the specified calendar directory.
/// The [id] parameter is the event title, used to find and delete the event file.
#[flutter_rust_bridge::frb]
pub fn delete_event(id: String, calendar_dir: String) -> Result<(), String> {
    let path = PathBuf::from(&calendar_dir);
    let repo = FileEventRepository::with_path(path.clone());

    // Delete by title - rcal-lib's delete_by_title_from_path uses the title
    repo.delete_by_title_from_path(&id, &path)
        .map_err(|e: Box<dyn std::error::Error>| e.to_string())?;

    Ok(())
}

// ============================================================================
// Event Validation Function
// ============================================================================

/// Validates an event and returns validation errors.
/// Returns Ok(()) if valid, Err(error_message) if invalid.
/// Uses the existing validation logic from rcal-lib.
#[flutter_rust_bridge::frb]
pub fn validate_event(
    title: String,
    start_date: String,
    end_date: Option<String>,
    start_time: Option<String>,
    end_time: Option<String>,
) -> Result<(), String> {
    // Validate title
    if !is_valid_title(&title) {
        return Err("Title cannot be empty or exceed maximum length".to_string());
    }

    // Parse and validate start date
    let start = parse_date(&start_date)?;

    // Validate end date >= start date
    if let Some(ref end_date_str) = end_date {
        let end = parse_date(end_date_str)?;
        if !is_valid_date_range(start, Some(end)) {
            return Err(format!(
                "End date ({}) cannot be before start date ({})",
                end_date_str, start_date
            ));
        }
    }

    // Validate time range for non-all-day events
    if !start_time.is_none() || !end_time.is_none() {
        let start_t = match start_time {
            Some(t) => parse_time(&t)?,
            None => return Err("Start time is required when end time is specified".to_string()),
        };

        let end_t = match end_time {
            Some(t) => Some(parse_time(&t)?),
            None => None,
        };

        if !is_valid_time_range(start_t, end_t) {
            return Err(format!("End time cannot be before start time"));
        }
    }

    Ok(())
}

// ============================================================================
// Recurring Event Instance Generation
// ============================================================================

/// Converts an EventDto to a CalendarEvent
#[allow(dead_code)]
fn dto_to_event(dto: &EventDto) -> Result<CalendarEvent, String> {
    create_calendar_event(
        dto.title.clone(),
        dto.description.clone(),
        dto.start_date.clone(),
        dto.end_date.clone(),
        dto.start_time.clone(),
        dto.end_time.clone(),
        dto.is_all_day,
        dto.recurrence.clone(),
        Some(dto.id.clone()),
    )
}

/// Generates instances for recurring events within a date range.
/// Uses rcal's generate_instances_for_range logic to expand recurring events.
#[flutter_rust_bridge::frb]
pub fn generate_instances(
    events: Vec<EventDto>,
    start_date: String,
    end_date: String,
) -> Vec<EventDto> {
    let start = match parse_date(&start_date) {
        Ok(d) => d,
        Err(_) => return vec![],
    };
    let end = match parse_date(&end_date) {
        Ok(d) => d,
        Err(_) => return vec![],
    };

    // Convert DTOs to CalendarEvents
    let calendar_events: Vec<CalendarEvent> = events
        .iter()
        .filter_map(|dto| dto_to_event(dto).ok())
        .collect();

    // Use EventService to generate instances
    let mut service = EventService::with_events(calendar_events);
    let instances = service.generate_instances_for_range(start, end);

    // Convert instances back to DTOs
    instances.iter().map(event_to_dto).collect()
}

// ============================================================================
// Event Occurrence Check
// ============================================================================

/// Converts an EventDto to a CalendarEvent for occurrence check
#[allow(dead_code)]
fn dto_to_event_for_occurs_on(dto: &EventDto) -> Result<CalendarEvent, String> {
    let mut event = create_calendar_event(
        dto.title.clone(),
        dto.description.clone(),
        dto.start_date.clone(),
        dto.end_date.clone(),
        dto.start_time.clone(),
        dto.end_time.clone(),
        dto.is_all_day,
        dto.recurrence.clone(),
        Some(dto.id.clone()),
    )?;
    event.is_recurring_instance = dto.is_recurring_instance;
    Ok(event)
}

/// Checks if an event occurs on a specific date.
/// Uses rcal's CalendarEvent::occurs_on logic.
#[flutter_rust_bridge::frb]
pub fn event_occurs_on(event: EventDto, date: String) -> bool {
    let event = match dto_to_event_for_occurs_on(&event) {
        Ok(e) => e,
        Err(_) => return false,
    };

    let target_date = match parse_date(&date) {
        Ok(d) => d,
        Err(_) => return false,
    };

    event.occurs_on(target_date)
}
