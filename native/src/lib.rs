mod frb_generated; /* AUTO INJECTED BY flutter_rust_bridge. This line may not be accurate, and you can change it according to your needs. */

use git2::Repository;
use std::path::Path;
use std::process::Command;
use std::ffi::{CStr, CString, c_char};

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
pub extern "C" fn add(left: i32, right: i32) -> i32 {
    left + right
}

// Git operations
fn git_init_impl(path: String) -> String {
    match Repository::init(&path) {
        Ok(_) => "Initialized empty Git repository".to_string(),
        Err(e) => format!("ERROR: {}", e),
    }
}

pub extern "C" fn git_init(path: *const c_char) -> *const c_char {
    let path = unsafe { CStr::from_ptr(path).to_str().unwrap().to_string() };
    let result = git_init_impl(path);
    let cstr = CString::new(result).unwrap();
    cstr.into_raw()
}

pub extern "C" fn git_add_remote(path: *const c_char, name: *const c_char, url: *const c_char) -> *const c_char {
    let path = unsafe { CStr::from_ptr(path).to_str().unwrap().to_string() };
    let name = unsafe { CStr::from_ptr(name).to_str().unwrap().to_string() };
    let url = unsafe { CStr::from_ptr(url).to_str().unwrap().to_string() };
    let result = match git_add_remote_impl(path, name, url) {
        Ok(s) => s,
        Err(e) => format!("ERROR: {}", e),
    };
    let cstr = CString::new(result).unwrap();
    cstr.into_raw()
}

pub extern "C" fn git_fetch(path: *const c_char, remote: *const c_char, username: *const c_char, password: *const c_char, ssh_key_path: *const c_char) -> *const c_char {
    let path = unsafe { CStr::from_ptr(path).to_str().unwrap().to_string() };
    let remote = unsafe { CStr::from_ptr(remote).to_str().unwrap().to_string() };
    let username = if username.is_null() { None } else { Some(unsafe { CStr::from_ptr(username).to_str().unwrap().to_string() }) };
    let password = if password.is_null() { None } else { Some(unsafe { CStr::from_ptr(password).to_str().unwrap().to_string() }) };
    let ssh_key_path = if ssh_key_path.is_null() { None } else { Some(unsafe { CStr::from_ptr(ssh_key_path).to_str().unwrap().to_string() }) };
    let result = match git_fetch_impl(path, remote, username, password, ssh_key_path) {
        Ok(s) => s,
        Err(e) => format!("ERROR: {}", e),
    };
    let cstr = CString::new(result).unwrap();
    cstr.into_raw()
}

pub extern "C" fn git_checkout(path: *const c_char, branch: *const c_char) -> *const c_char {
    let path = unsafe { CStr::from_ptr(path).to_str().unwrap().to_string() };
    let branch = unsafe { CStr::from_ptr(branch).to_str().unwrap().to_string() };
    let result = match git_checkout_impl(path, branch) {
        Ok(s) => s,
        Err(e) => format!("ERROR: {}", e),
    };
    let cstr = CString::new(result).unwrap();
    cstr.into_raw()
}

pub extern "C" fn git_pull(path: *const c_char, username: *const c_char, password: *const c_char, ssh_key_path: *const c_char) -> *const c_char {
    let path = unsafe { CStr::from_ptr(path).to_str().unwrap().to_string() };
    let username = if username.is_null() { None } else { Some(unsafe { CStr::from_ptr(username).to_str().unwrap().to_string() }) };
    let password = if password.is_null() { None } else { Some(unsafe { CStr::from_ptr(password).to_str().unwrap().to_string() }) };
    let ssh_key_path = if ssh_key_path.is_null() { None } else { Some(unsafe { CStr::from_ptr(ssh_key_path).to_str().unwrap().to_string() }) };
    let result = match git_pull_impl(path, username, password, ssh_key_path) {
        Ok(s) => s,
        Err(e) => format!("ERROR: {}", e),
    };
    let cstr = CString::new(result).unwrap();
    cstr.into_raw()
}

pub extern "C" fn git_status(path: *const c_char) -> *const c_char {
    let path = unsafe { CStr::from_ptr(path).to_str().unwrap().to_string() };
    let result = match git_status_impl(path) {
        Ok(s) => s,
        Err(e) => format!("ERROR: {}", e),
    };
    let cstr = CString::new(result).unwrap();
    cstr.into_raw()
}

pub extern "C" fn git_add_all(path: *const c_char) -> *const c_char {
    let path = unsafe { CStr::from_ptr(path).to_str().unwrap().to_string() };
    let result = match git_add_all_impl(path) {
        Ok(s) => s,
        Err(e) => format!("ERROR: {}", e),
    };
    let cstr = CString::new(result).unwrap();
    cstr.into_raw()
}

pub extern "C" fn git_commit(path: *const c_char, message: *const c_char) -> *const c_char {
    let path = unsafe { CStr::from_ptr(path).to_str().unwrap().to_string() };
    let message = unsafe { CStr::from_ptr(message).to_str().unwrap().to_string() };
    let result = match git_commit_impl(path, message) {
        Ok(s) => s,
        Err(e) => format!("ERROR: {}", e),
    };
    let cstr = CString::new(result).unwrap();
    cstr.into_raw()
}

pub extern "C" fn git_push(path: *const c_char, username: *const c_char, password: *const c_char, ssh_key_path: *const c_char) -> *const c_char {
    let path = unsafe { CStr::from_ptr(path).to_str().unwrap().to_string() };
    let username = if username.is_null() { None } else { Some(unsafe { CStr::from_ptr(username).to_str().unwrap().to_string() }) };
    let password = if password.is_null() { None } else { Some(unsafe { CStr::from_ptr(password).to_str().unwrap().to_string() }) };
    let ssh_key_path = if ssh_key_path.is_null() { None } else { Some(unsafe { CStr::from_ptr(ssh_key_path).to_str().unwrap().to_string() }) };
    let result = match git_push_impl(path, username, password, ssh_key_path) {
        Ok(s) => s,
        Err(e) => format!("ERROR: {}", e),
    };
    let cstr = CString::new(result).unwrap();
    cstr.into_raw()
}

pub extern "C" fn git_merge_prefer_remote(path: *const c_char) -> *const c_char {
    let path = unsafe { CStr::from_ptr(path).to_str().unwrap().to_string() };
    let result = match git_merge_prefer_remote_impl(path) {
        Ok(s) => s,
        Err(e) => format!("ERROR: {}", e),
    };
    let cstr = CString::new(result).unwrap();
    cstr.into_raw()
}

pub extern "C" fn git_merge_abort(path: *const c_char) -> *const c_char {
    let path = unsafe { CStr::from_ptr(path).to_str().unwrap().to_string() };
    let result = match git_merge_abort_impl(path) {
        Ok(s) => s,
        Err(e) => format!("ERROR: {}", e),
    };
    let cstr = CString::new(result).unwrap();
    cstr.into_raw()
}

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
pub fn git_current_branch(path: String) -> Result<String, String> {
    let repo = Repository::open(&path).map_err(|e| e.to_string())?;
    let head_ref = repo.head().map_err(|e| e.to_string())?;
    let branch_name = head_ref.name().and_then(|n| n.strip_prefix("refs/heads/")).unwrap_or("unknown");
    Ok(branch_name.to_string())
}

#[flutter_rust_bridge::frb]
pub fn git_list_branches(path: String) -> Result<Vec<String>, String> {
    let repo = Repository::open(&path).map_err(|e| e.to_string())?;
    let branches = repo.branches(None).map_err(|e| e.to_string())?;
    let mut branch_names = Vec::new();
    for branch_result in branches {
        let (branch, _) = branch_result.map_err(|e| e.to_string())?;
        if let Some(name) = branch.name().map_err(|e| e.to_string())? {
            branch_names.push(name.to_string());
        }
    }
    Ok(branch_names)
}

fn git_pull_impl(path: String, username: Option<String>, password: Option<String>, ssh_key_path: Option<String>) -> Result<String, String> {
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

fn git_push_impl(path: String, username: Option<String>, password: Option<String>, ssh_key_path: Option<String>) -> Result<String, String> {
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

fn git_status_impl(path: String) -> Result<String, String> {
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

fn git_add_remote_impl(path: String, name: String, url: String) -> Result<String, String> {
    let repo = Repository::open(&path).map_err(|e| e.to_string())?;
    repo.remote(&name, &url).map_err(|e| e.to_string())?;
    Ok("Remote added".to_string())
}

fn git_fetch_impl(path: String, remote: String, username: Option<String>, password: Option<String>, ssh_key_path: Option<String>) -> Result<String, String> {
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

fn git_checkout_impl(path: String, branch: String) -> Result<String, String> {
    let repo = Repository::open(&path).map_err(|e| e.to_string())?;
    let obj = repo.revparse_single(&branch).map_err(|e| e.to_string())?;
    repo.checkout_tree(&obj, None).map_err(|e| e.to_string())?;
    repo.set_head(&format!("refs/heads/{}", branch)).map_err(|e| e.to_string())?;
    Ok("Checked out".to_string())
}

fn git_add_all_impl(path: String) -> Result<String, String> {
    let repo = Repository::open(&path).map_err(|e| e.to_string())?;
    let mut index = repo.index().map_err(|e| e.to_string())?;
    index.add_all(["*"].iter(), git2::IndexAddOption::DEFAULT, None).map_err(|e| e.to_string())?;
    index.write().map_err(|e| e.to_string())?;
    Ok("Added all".to_string())
}

fn git_commit_impl(path: String, message: String) -> Result<String, String> {
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

fn git_merge_prefer_remote_impl(path: String) -> Result<String, String> {
    let output = Command::new("git")
        .arg("checkout")
        .arg("--theirs")
        .arg(".")
        .current_dir(&path)
        .output()
        .map_err(|e| e.to_string())?;
    if !output.status.success() {
        return Err(String::from_utf8_lossy(&output.stderr).to_string());
    }
    let output = Command::new("git")
        .arg("add")
        .arg(".")
        .current_dir(&path)
        .output()
        .map_err(|e| e.to_string())?;
    if !output.status.success() {
        return Err(String::from_utf8_lossy(&output.stderr).to_string());
    }
    let output = Command::new("git")
        .arg("commit")
        .arg("-m")
        .arg("Merge resolved by preferring remote")
        .current_dir(&path)
        .output()
        .map_err(|e| e.to_string())?;
    if !output.status.success() {
        return Err(String::from_utf8_lossy(&output.stderr).to_string());
    }
    Ok("Merge resolved by preferring remote".to_string())
}

fn git_merge_abort_impl(path: String) -> Result<String, String> {
    let output = Command::new("git")
        .arg("merge")
        .arg("--abort")
        .current_dir(&path)
        .output()
        .map_err(|e| e.to_string())?;
    if !output.status.success() {
        return Err(String::from_utf8_lossy(&output.stderr).to_string());
    }
    Ok("Merge aborted".to_string())
}

#[cfg(test)]
mod tests {
    use super::*;
    use std::fs;
    use tempdir::TempDir;

    #[test]
    fn test_add() {
        assert_eq!(add(2, 3), 5);
    }

    #[test]
    fn test_git_init() {
        let temp_dir = TempDir::new("test_git_init").unwrap();
        let path = temp_dir.path().to_str().unwrap().to_string();
        let result = git_init(path.clone());
        assert!(result.is_ok());
        assert!(fs::metadata(format!("{}/.git", path)).is_ok());
    }

    #[test]
    fn test_invalid_path() {
        // Test error handling for invalid paths
        let result = git_status("/invalid/path".to_string());
        assert!(result.is_err());
    }

    #[test]
    fn test_git_merge_prefer_remote() {
        let temp_dir = TempDir::new("test_merge_prefer_remote").unwrap();
        let path = temp_dir.path().to_str().unwrap().to_string();

        // Initialize repo
        git_init(path.clone()).unwrap();

        // Create and commit a file
        fs::write(format!("{}/test.txt", path), "initial content").unwrap();
        git_add_all(path.clone()).unwrap();
        git_commit(path.clone(), "Initial commit".to_string()).unwrap();

        // Create branch
        let output = Command::new("git")
            .arg("checkout")
            .arg("-b")
            .arg("feature")
            .current_dir(&path)
            .output()
            .unwrap();
        assert!(output.status.success());

        // Modify file in feature branch
        fs::write(format!("{}/test.txt", path), "feature content").unwrap();
        git_add_all(path.clone()).unwrap();
        git_commit(path.clone(), "Feature commit".to_string()).unwrap();

        // Switch back to master and modify the same file
        let output = Command::new("git")
            .arg("checkout")
            .arg("master")
            .current_dir(&path)
            .output()
            .unwrap();
        assert!(output.status.success());
        fs::write(format!("{}/test.txt", path), "master content").unwrap();
        git_add_all(path.clone()).unwrap();
        git_commit(path.clone(), "Master commit".to_string()).unwrap();

        // Merge feature branch to create conflict
        let output = Command::new("git")
            .arg("merge")
            .arg("feature")
            .current_dir(&path)
            .output()
            .unwrap();
        // Expect conflict
        assert!(!output.status.success());

        // Now test prefer remote (feature branch)
        let result = git_merge_prefer_remote(path.clone());
        assert!(result.is_ok());
        assert_eq!(result.unwrap(), "Merge resolved by preferring remote".to_string());

        // Check content is from feature
        let content = fs::read_to_string(format!("{}/test.txt", path)).unwrap();
        assert_eq!(content, "feature content");
    }

    #[test]
    fn test_git_merge_abort() {
        let temp_dir = TempDir::new("test_merge_abort").unwrap();
        let path = temp_dir.path().to_str().unwrap().to_string();

        // Initialize repo
        git_init(path.clone()).unwrap();

        // Create and commit a file
        fs::write(format!("{}/test.txt", path), "initial content").unwrap();
        git_add_all(path.clone()).unwrap();
        git_commit(path.clone(), "Initial commit".to_string()).unwrap();

        // Create branch
        let output = Command::new("git")
            .arg("checkout")
            .arg("-b")
            .arg("feature")
            .current_dir(&path)
            .output()
            .unwrap();
        assert!(output.status.success());

        // Modify file in feature branch
        fs::write(format!("{}/test.txt", path), "feature content").unwrap();
        git_add_all(path.clone()).unwrap();
        git_commit(path.clone(), "Feature commit".to_string()).unwrap();

        // Switch back to master and modify the same file
        let output = Command::new("git")
            .arg("checkout")
            .arg("master")
            .current_dir(&path)
            .output()
            .unwrap();
        assert!(output.status.success());
        fs::write(format!("{}/test.txt", path), "master content").unwrap();
        git_add_all(path.clone()).unwrap();
        git_commit(path.clone(), "Master commit".to_string()).unwrap();

        // Merge feature branch to create conflict
        let output = Command::new("git")
            .arg("merge")
            .arg("feature")
            .current_dir(&path)
            .output()
            .unwrap();
        assert!(!output.status.success());

        // Now test abort
        let result = git_merge_abort(path.clone());
        assert!(result.is_ok());
        assert_eq!(result.unwrap(), "Merge aborted".to_string());

        // Check content is back to master
        let content = fs::read_to_string(format!("{}/test.txt", path)).unwrap();
        assert_eq!(content, "master content");
    }
}