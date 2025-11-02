use git2::Repository;
use std::path::Path;
use std::process::Command;

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
    callbacks.credentials(move |url, _, _| get_credentials(url, &username, &password, &ssh_key_path));
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

fn git_pull_impl(path: String, username: Option<String>, password: Option<String>, ssh_key_path: Option<String>) -> Result<String, GitError> {
    let repo = Repository::open(&path)?;
    let head_ref = repo.head()?;
    let branch_name = head_ref.name().and_then(|n| n.strip_prefix("refs/heads/")).map(|s| s.to_string()).unwrap_or_else(|| {
        repo.find_remote("origin").ok()
            .and_then(|remote| remote.default_branch().ok().map(|buf| String::from_utf8_lossy(&buf).into_owned()))
            .unwrap_or("main".to_string())
    });
    let mut remote = repo.find_remote("origin")?;
    let mut callbacks = git2::RemoteCallbacks::new();
    let username = username.clone();
    let password = password.clone();
    let ssh_key_path = ssh_key_path.clone();
    callbacks.credentials(move |url, _, _| get_credentials(url, &username, &password, &ssh_key_path));
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
        let mut reference = repo.find_reference(&refname)?;
        reference.set_target(fetch_commit.id(), "Fast-forward")?;
        repo.set_head(&refname)?;
        repo.checkout_head(None)?;
        Ok("Fast-forward merge completed".to_string())
    } else {
        Err(GitError::Other("Non-fast-forward merge required".to_string()))
    }
}

#[flutter_rust_bridge::frb]
pub fn git_pull(path: String, username: Option<String>, password: Option<String>, ssh_key_path: Option<String>) -> Result<String, GitError> {
    git_pull_impl(path, username, password, ssh_key_path)
}

fn git_push_impl(path: String, username: Option<String>, password: Option<String>, ssh_key_path: Option<String>) -> Result<String, GitError> {
    let repo = Repository::open(&path)?;
    let head_ref = repo.head()?;
    let branch_name = head_ref.name().and_then(|n| n.strip_prefix("refs/heads/")).map(|s| s.to_string()).unwrap_or_else(|| {
        repo.find_remote("origin").ok()
            .and_then(|remote| remote.default_branch().ok().map(|buf| String::from_utf8_lossy(&buf).into_owned()))
            .unwrap_or("main".to_string())
    });
    let mut remote = repo.find_remote("origin")?;
    let mut callbacks = git2::RemoteCallbacks::new();
    let username = username.clone();
    let password = password.clone();
    let ssh_key_path = ssh_key_path.clone();
    callbacks.credentials(move |url, _, _| get_credentials(url, &username, &password, &ssh_key_path));
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
    let head_ref = repo.head()?;
    let branch_name = head_ref.name().and_then(|n| n.strip_prefix("refs/heads/")).map(|s| s.to_string()).unwrap_or_else(|| {
        repo.find_remote("origin").ok()
            .and_then(|remote| remote.default_branch().ok().map(|buf| String::from_utf8_lossy(&buf).into_owned()))
            .unwrap_or("main".to_string())
    });
    let mut remote_obj = repo.find_remote(&remote)?;
    let mut callbacks = git2::RemoteCallbacks::new();
    let username = username.clone();
    let password = password.clone();
    let ssh_key_path = ssh_key_path.clone();
    callbacks.credentials(move |url, _, _| get_credentials(url, &username, &password, &ssh_key_path));
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