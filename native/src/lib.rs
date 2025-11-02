mod frb_generated; /* AUTO INJECTED BY flutter_rust_bridge. This line may not be accurate, and you can change it according to your needs. */
// This file initializes the dynamic library and exposes the public API

use flutter_rust_bridge::*;
use git2::Repository;
use std::path::Path;

// Helper function for credentials
fn get_credentials(url: &str, username: &Option<String>, password: &Option<String>, ssh_key_path: &Option<String>) -> git2::Cred {
    if url.starts_with("http") || url.starts_with("https") {
        if let (Some(user), Some(pass)) = (username, password) {
            git2::Cred::userpass_plaintext(user, pass).expect("userpass error")
        } else {
            panic!("Credentials required for HTTPS")
        }
    } else {
        if let Some(key_path) = ssh_key_path {
            git2::Cred::ssh_key("git", None, Path::new(key_path), None).expect("SSH key error")
        } else {
            git2::Cred::ssh_key_from_agent("git").expect("SSH agent error")
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
#[flutter_rust_bridge::frb]
pub fn git_init(path: String) -> Result<String, String> {
    match Repository::init(&path) {
        Ok(_) => Ok("Initialized empty Git repository".to_string()),
        Err(e) => Err(e.to_string()),
    }
}

#[flutter_rust_bridge::frb]
pub fn git_clone(url: String, path: String, username: Option<String>, password: Option<String>, ssh_key_path: Option<String>) -> Result<String, String> {
    let mut callbacks = git2::RemoteCallbacks::new();
    let username = username.clone();
    let password = password.clone();
    let ssh_key_path = ssh_key_path.clone();
    callbacks.credentials(move |url, _, _| Ok(get_credentials(url, &username, &password, &ssh_key_path)));
    let mut fetch_options = git2::FetchOptions::new();
    fetch_options.remote_callbacks(callbacks);
    let mut builder = git2::build::RepoBuilder::new();
    builder.fetch_options(fetch_options);
    match builder.clone(&url, Path::new(&path)) {
        Ok(_) => Ok("Repository cloned successfully".to_string()),
        Err(e) => Err(e.to_string()),
    }
}

#[flutter_rust_bridge::frb]
pub fn git_pull(path: String, username: Option<String>, password: Option<String>, ssh_key_path: Option<String>) -> Result<String, String> {
    let repo = Repository::open(&path).map_err(|e| e.to_string())?;
    let head_ref = repo.head().map_err(|e| e.to_string())?;
    let branch_name = head_ref.name().and_then(|n| n.strip_prefix("refs/heads/")).unwrap_or("master");
    let mut remote = repo.find_remote("origin").map_err(|e| e.to_string())?;
    let mut callbacks = git2::RemoteCallbacks::new();
    let username = username.clone();
    let password = password.clone();
    let ssh_key_path = ssh_key_path.clone();
    callbacks.credentials(move |url, _, _| Ok(get_credentials(url, &username, &password, &ssh_key_path)));
    let mut fetch_options = git2::FetchOptions::new();
    fetch_options.remote_callbacks(callbacks);
    remote.fetch(&[branch_name], Some(&mut fetch_options), None).map_err(|e| e.to_string())?;
    let fetch_head = repo.find_reference("FETCH_HEAD").map_err(|e| e.to_string())?;
    let fetch_commit = repo.reference_to_annotated_commit(&fetch_head).map_err(|e| e.to_string())?;
    let analysis = repo.merge_analysis(&[&fetch_commit]).map_err(|e| e.to_string())?;
    if analysis.0.is_up_to_date() {
        Ok("Already up to date".to_string())
    } else if analysis.0.is_fast_forward() {
        let refname = format!("refs/heads/{}", branch_name);
        let mut reference = repo.find_reference(&refname).map_err(|e| e.to_string())?;
        reference.set_target(fetch_commit.id(), "Fast-forward").map_err(|e| e.to_string())?;
        repo.set_head(&refname).map_err(|e| e.to_string())?;
        repo.checkout_head(None).map_err(|e| e.to_string())?;
        Ok("Fast-forward merge completed".to_string())
    } else {
        Err("Non-fast-forward merge required".to_string())
    }
}

#[flutter_rust_bridge::frb]
pub fn git_push(path: String, username: Option<String>, password: Option<String>, ssh_key_path: Option<String>) -> Result<String, String> {
    let repo = Repository::open(&path).map_err(|e| e.to_string())?;
    let head_ref = repo.head().map_err(|e| e.to_string())?;
    let branch_name = head_ref.name().and_then(|n| n.strip_prefix("refs/heads/")).unwrap_or("master");
    let mut remote = repo.find_remote("origin").map_err(|e| e.to_string())?;
    let mut callbacks = git2::RemoteCallbacks::new();
    let username = username.clone();
    let password = password.clone();
    let ssh_key_path = ssh_key_path.clone();
    callbacks.credentials(move |url, _, _| Ok(get_credentials(url, &username, &password, &ssh_key_path)));
    let mut push_options = git2::PushOptions::new();
    push_options.remote_callbacks(callbacks);
    let refspec = format!("refs/heads/{}", branch_name);
    remote.push(&[&refspec], Some(&mut push_options)).map_err(|e| e.to_string())?;
    Ok("Pushed successfully".to_string())
}

#[flutter_rust_bridge::frb]
pub fn git_status(path: String) -> Result<String, String> {
    let repo = Repository::open(&path).map_err(|e| e.to_string())?;
    let statuses = repo.statuses(None).map_err(|e| e.to_string())?;
    let mut status_str = String::new();
    for entry in statuses.iter() {
        let path = entry.path().unwrap_or("unknown");
        let status = entry.status();
        status_str.push_str(&format!("{}: {:?}\n", path, status));
    }
    if status_str.is_empty() {
        Ok("Working directory clean".to_string())
    } else {
        Ok(status_str)
    }
}

#[flutter_rust_bridge::frb]
pub fn git_add_remote(path: String, name: String, url: String) -> Result<String, String> {
    let repo = Repository::open(&path).map_err(|e| e.to_string())?;
    repo.remote(&name, &url).map_err(|e| e.to_string())?;
    Ok("Remote added".to_string())
}

#[flutter_rust_bridge::frb]
pub fn git_fetch(path: String, remote: String, username: Option<String>, password: Option<String>, ssh_key_path: Option<String>) -> Result<String, String> {
    let repo = Repository::open(&path).map_err(|e| e.to_string())?;
    let head_ref = repo.head().map_err(|e| e.to_string())?;
    let branch_name = head_ref.name().and_then(|n| n.strip_prefix("refs/heads/")).unwrap_or("master");
    let mut remote = repo.find_remote(&remote).map_err(|e| e.to_string())?;
    let mut callbacks = git2::RemoteCallbacks::new();
    let username = username.clone();
    let password = password.clone();
    let ssh_key_path = ssh_key_path.clone();
    callbacks.credentials(move |url, _, _| Ok(get_credentials(url, &username, &password, &ssh_key_path)));
    let mut fetch_options = git2::FetchOptions::new();
    fetch_options.remote_callbacks(callbacks);
    remote.fetch(&[branch_name], Some(&mut fetch_options), None).map_err(|e| e.to_string())?;
    Ok("Fetched".to_string())
}

#[flutter_rust_bridge::frb]
pub fn git_checkout(path: String, branch: String) -> Result<String, String> {
    let repo = Repository::open(&path).map_err(|e| e.to_string())?;
    let obj = repo.revparse_single(&branch).map_err(|e| e.to_string())?;
    repo.checkout_tree(&obj, None).map_err(|e| e.to_string())?;
    repo.set_head(&format!("refs/heads/{}", branch)).map_err(|e| e.to_string())?;
    Ok("Checked out".to_string())
}

#[flutter_rust_bridge::frb]
pub fn git_add_all(path: String) -> Result<String, String> {
    let repo = Repository::open(&path).map_err(|e| e.to_string())?;
    let mut index = repo.index().map_err(|e| e.to_string())?;
    index.add_all(["*"].iter(), git2::IndexAddOption::DEFAULT, None).map_err(|e| e.to_string())?;
    index.write().map_err(|e| e.to_string())?;
    Ok("Added all".to_string())
}

#[flutter_rust_bridge::frb]
pub fn git_commit(path: String, message: String) -> Result<String, String> {
    let repo = Repository::open(&path).map_err(|e| e.to_string())?;
    let mut index = repo.index().map_err(|e| e.to_string())?;
    let oid = index.write_tree().map_err(|e| e.to_string())?;
    let tree = repo.find_tree(oid).map_err(|e| e.to_string())?;
    let signature = git2::Signature::now("App", "app@example.com").map_err(|e| e.to_string())?;
    let parent_commit = repo.head().ok().and_then(|head| head.target()).and_then(|oid| repo.find_commit(oid).ok());
    let commit = if let Some(parent) = parent_commit {
        repo.commit(Some("HEAD"), &signature, &signature, &message, &tree, &[&parent]).map_err(|e| e.to_string())?
    } else {
        repo.commit(Some("HEAD"), &signature, &signature, &message, &tree, &[]).map_err(|e| e.to_string())?
    };
    Ok(commit.to_string())
}

#[flutter_rust_bridge::frb]
pub fn git_merge_prefer_remote(_path: String) -> Result<String, String> {
    Ok("Prefer remote resolution not implemented".to_string())
}

#[flutter_rust_bridge::frb]
pub fn git_merge_abort(_path: String) -> Result<String, String> {
    Ok("Merge abort not implemented".to_string())
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_add() {
        assert_eq!(add(2, 3), 5);
    }

    // Note: Git function tests require actual repos, so these are placeholders
    #[test]
    fn test_git_init() {
        // Placeholder: test git_init with temp dir
        // This would require creating a temp directory and checking if .git exists
    }

    #[test]
    fn test_invalid_path() {
        // Test error handling for invalid paths
        let result = git_status("/invalid/path".to_string());
        assert!(result.is_err());
    }
}