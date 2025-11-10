use git2::{Repository, Delta};
use std::fs;
use std::path::Path;
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

// Helper function for credentials
fn get_credentials(url: &str, username: &Option<String>, password: &Option<String>, ssh_key_path: &Option<String>) -> Result<git2::Cred, git2::Error> {
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
    Err(format!("Hostname '{}' does not match certificate", hostname))
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
pub fn git_clone(url: String, path: String, username: Option<String>, password: Option<String>, ssh_key_path: Option<String>) -> Result<String, GitError> {
    let mut callbacks = git2::RemoteCallbacks::new();
    let username = username.clone();
    let password = password.clone();
    let ssh_key_path = ssh_key_path.clone();
    let _url_clone = url.clone();
    callbacks.credentials(move |url, _, _| get_credentials(url, &username, &password, &ssh_key_path));
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
    let branch_name = head_ref.name().and_then(|n| n.strip_prefix("refs/heads/")).unwrap_or("unknown");
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
        status.contains(git2::Status::WT_MODIFIED) ||
        status.contains(git2::Status::WT_DELETED) ||
        status.contains(git2::Status::WT_NEW) ||
        status.contains(git2::Status::INDEX_MODIFIED) ||
        status.contains(git2::Status::INDEX_DELETED) ||
        status.contains(git2::Status::INDEX_NEW)
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
fn git_pull_impl(path: String, username: Option<String>, password: Option<String>, ssh_key_path: Option<String>) -> Result<String, GitError> {
    let mut repo = Repository::open(&path)?;
    let has_changes = has_local_changes(&repo)?;
    let mut stashed = false;
    let old_tree = repo.head()?.peel_to_tree()?;
    let old_oid = old_tree.id();
    drop(old_tree);
    let mut new_tree: Option<git2::Tree> = None;

    // Stash local changes to allow pull to update working directory
    if has_changes {
        let signature = git2::Signature::now("App", "app@example.com")?;
        repo.stash_save(&signature, "Stashed by app during pull", None)?;
        stashed = true;
    }

    let result = (|| {
        let branch_name = if let Ok(head_ref) = repo.head() {
            head_ref.name().and_then(|n| n.strip_prefix("refs/heads/")).unwrap_or("unknown").to_string()
        } else {
            repo.find_remote("origin").ok()
                .and_then(|remote| remote.default_branch().ok().map(|buf| String::from_utf8_lossy(&buf).into_owned()))
                .unwrap_or("main".to_string())
        };
        let mut remote = repo.find_remote("origin")?;
        let mut callbacks = git2::RemoteCallbacks::new();
        let username = username.clone();
        let password = password.clone();
        let ssh_key_path = ssh_key_path.clone();
        callbacks.credentials(move |url, _, _| get_credentials(url, &username, &password, &ssh_key_path));
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
            Err(GitError::Other("Non-fast-forward merge required".to_string()))
        }
    })();

    let deleted_paths: Vec<String> = if result.is_ok() {
        if let Some(new_tree) = &new_tree {
            let old_tree = repo.find_tree(old_oid)?;
            let diff = repo.diff_tree_to_tree(Some(&old_tree), Some(new_tree), None)?;
            diff.deltas().filter(|d| d.status() == Delta::Deleted).map(|d| d.old_file().path().unwrap().to_string_lossy().to_string()).collect()
        } else {
            vec![]
        }
    } else {
        vec![]
    };
    drop(new_tree);

    // Handle stash restoration after pull operation
    if stashed {
        if result.is_ok() {
            // Pull succeeded, try to restore local changes
            if let Err(_) = repo.stash_pop(0, None) {
                // Stash pop failed (conflicts with remote changes), drop stash to prefer remote
                let _ = repo.stash_drop(0);
            }
            // Enforce deletions after stash pop
            for path in deleted_paths {
                if let Some(workdir) = repo.workdir() {
                    let full_path = workdir.join(path);
                    if full_path.exists() {
                        if let Err(e) = fs::remove_file(&full_path) {
                            eprintln!("Failed to remove deleted file {}: {}", full_path.display(), e);
                        }
                    }
                }
            }
        } else {
            // Pull failed, restore local changes to original state
            let _ = repo.stash_pop(0, None);
        }
    }

    result
}

#[flutter_rust_bridge::frb]
pub fn git_pull(path: String, username: Option<String>, password: Option<String>, ssh_key_path: Option<String>) -> Result<String, GitError> {
    git_pull_impl(path, username, password, ssh_key_path)
}

fn git_push_impl(path: String, username: Option<String>, password: Option<String>, ssh_key_path: Option<String>) -> Result<String, GitError> {
    let repo = Repository::open(&path)?;
    let branch_name = if let Ok(head_ref) = repo.head() {
        head_ref.name().and_then(|n| n.strip_prefix("refs/heads/")).unwrap_or("unknown").to_string()
    } else {
        repo.find_remote("origin").ok()
            .and_then(|remote| remote.default_branch().ok().map(|buf| String::from_utf8_lossy(&buf).into_owned()))
            .unwrap_or("main".to_string())
    };
    let mut remote = repo.find_remote("origin")?;
    let mut callbacks = git2::RemoteCallbacks::new();
    let username = username.clone();
    let password = password.clone();
    let ssh_key_path = ssh_key_path.clone();
    callbacks.credentials(move |url, _, _| get_credentials(url, &username, &password, &ssh_key_path));
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
pub fn git_push(path: String, username: Option<String>, password: Option<String>, ssh_key_path: Option<String>) -> Result<String, GitError> {
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

fn git_fetch_impl(path: String, remote: String, username: Option<String>, password: Option<String>, ssh_key_path: Option<String>) -> Result<String, GitError> {
    let repo = Repository::open(&path)?;
    let branch_name = if let Ok(head_ref) = repo.head() {
        head_ref.name().and_then(|n| n.strip_prefix("refs/heads/")).unwrap_or("unknown").to_string()
    } else {
        repo.find_remote("origin").ok()
            .and_then(|remote| remote.default_branch().ok().map(|buf| String::from_utf8_lossy(&buf).into_owned()))
            .unwrap_or("main".to_string())
    };
    let mut remote_obj = repo.find_remote(&remote)?;
    let mut callbacks = git2::RemoteCallbacks::new();
    let username = username.clone();
    let password = password.clone();
    let ssh_key_path = ssh_key_path.clone();
    callbacks.credentials(move |url, _, _| get_credentials(url, &username, &password, &ssh_key_path));
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
pub fn git_fetch(path: String, remote: String, username: Option<String>, password: Option<String>, ssh_key_path: Option<String>) -> Result<String, GitError> {
    git_fetch_impl(path, remote, username, password, ssh_key_path)
}

fn git_checkout_impl(path: String, branch: String) -> Result<String, GitError> {
    let repo = Repository::open(&path)?;
    let obj = repo.revparse_single(&branch)?;
    repo.checkout_tree(&obj, None)?;
    repo.set_head(&format!("refs/heads/{}", branch))?;
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
    let parent_commit = repo.head().ok().and_then(|head| head.target()).and_then(|oid| repo.find_commit(oid).ok());
    let commit = if let Some(parent) = parent_commit {
        repo.commit(Some("HEAD"), &signature, &signature, &message, &tree, &[&parent])?
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
        return Err(GitError::Other(String::from_utf8_lossy(&output.stderr).to_string()));
    }
    let output = Command::new("git")
        .arg("add")
        .arg(".")
        .current_dir(&path)
        .output()?;
    if !output.status.success() {
        return Err(GitError::Other(String::from_utf8_lossy(&output.stderr).to_string()));
    }
    let output = Command::new("git")
        .arg("commit")
        .arg("-m")
        .arg("Merge resolved by preferring remote")
        .current_dir(&path)
        .output()?;
    if !output.status.success() {
        return Err(GitError::Other(String::from_utf8_lossy(&output.stderr).to_string()));
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
        diff_str.push_str(&format!("{:?} {:?} {:?}\n", delta.old_file().path(), delta.new_file().path(), line.origin()));
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
        return Err(GitError::Other(String::from_utf8_lossy(&output.stderr).to_string()));
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