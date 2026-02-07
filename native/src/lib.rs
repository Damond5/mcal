#![allow(unexpected_cfgs)]

mod api;
mod frb_generated; /* AUTO INJECTED BY flutter_rust_bridge. This line may not be accurate, and you can change it according to your needs. */

#[cfg(test)]
mod tests {
    use super::*;
    use std::fs;
    use std::process::Command;
    use tempdir::TempDir;

    #[test]
    fn test_add() {
        assert_eq!(api::add(2, 3), 5);
    }

    #[test]
    fn test_git_init() {
        let temp_dir = TempDir::new("test_git_init").unwrap();
        let path = temp_dir.path().to_str().unwrap().to_string();
        let result = api::git_init(path.clone());
        assert!(result.is_ok());
        assert!(fs::metadata(format!("{}/.git", path)).is_ok());
    }

    #[test]
    fn test_invalid_path() {
        // Test error handling for invalid paths
        let result = api::git_status("/invalid/path".to_string());
        assert!(result.is_err());
    }

    #[test]
    fn test_git_merge_prefer_remote() {
        let temp_dir = TempDir::new("test_merge_prefer_remote").unwrap();
        let path = temp_dir.path().to_str().unwrap().to_string();

        // Initialize repo
        api::git_init(path.clone()).unwrap();

        // Create and commit a file
        fs::write(format!("{}/test.txt", path), "initial content").unwrap();
        api::git_add_all(path.clone()).unwrap();
        api::git_commit(path.clone(), "Initial commit".to_string()).unwrap();

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
        api::git_add_all(path.clone()).unwrap();
        api::git_commit(path.clone(), "Feature commit".to_string()).unwrap();

        // Switch back to master and modify the same file
        let output = Command::new("git")
            .arg("checkout")
            .arg("master")
            .current_dir(&path)
            .output()
            .unwrap();
        assert!(output.status.success());
        fs::write(format!("{}/test.txt", path), "master content").unwrap();
        api::git_add_all(path.clone()).unwrap();
        api::git_commit(path.clone(), "Master commit".to_string()).unwrap();

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
        let result = api::git_merge_prefer_remote(path.clone());
        assert!(result.is_ok());
        assert_eq!(
            result.unwrap(),
            "Merge resolved by preferring remote".to_string()
        );

        // Check content is from feature
        let content = fs::read_to_string(format!("{}/test.txt", path)).unwrap();
        assert_eq!(content, "feature content");
    }

    #[test]
    fn test_git_merge_abort() {
        let temp_dir = TempDir::new("test_merge_abort").unwrap();
        let path = temp_dir.path().to_str().unwrap().to_string();

        // Initialize repo
        api::git_init(path.clone()).unwrap();

        // Create and commit a file
        fs::write(format!("{}/test.txt", path), "initial content").unwrap();
        api::git_add_all(path.clone()).unwrap();
        api::git_commit(path.clone(), "Initial commit".to_string()).unwrap();

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
        api::git_add_all(path.clone()).unwrap();
        api::git_commit(path.clone(), "Feature commit".to_string()).unwrap();

        // Switch back to master and modify the same file
        let output = Command::new("git")
            .arg("checkout")
            .arg("master")
            .current_dir(&path)
            .output()
            .unwrap();
        assert!(output.status.success());
        fs::write(format!("{}/test.txt", path), "master content").unwrap();
        api::git_add_all(path.clone()).unwrap();
        api::git_commit(path.clone(), "Master commit".to_string()).unwrap();

        // Merge feature branch to create conflict
        let output = Command::new("git")
            .arg("merge")
            .arg("feature")
            .current_dir(&path)
            .output()
            .unwrap();
        assert!(!output.status.success());

        // Now test abort
        let result = api::git_merge_abort(path.clone());
        assert!(result.is_ok());
        assert_eq!(result.unwrap(), "Merge aborted".to_string());

        // Check content is back to master
        let content = fs::read_to_string(format!("{}/test.txt", path)).unwrap();
        assert_eq!(content, "master content");
    }

    #[test]
    fn test_has_local_changes() {
        let temp_dir = TempDir::new("test_has_local_changes").unwrap();
        let path = temp_dir.path().to_str().unwrap().to_string();

        // Initialize repo
        api::git_init(path.clone()).unwrap();

        // Create and commit a file
        fs::write(format!("{}/test.txt", path), "initial content").unwrap();
        api::git_add_all(path.clone()).unwrap();
        api::git_commit(path.clone(), "Initial commit".to_string()).unwrap();

        // No changes
        assert!(!api::git_has_local_changes(path.clone()).unwrap());

        // Modify file
        fs::write(format!("{}/test.txt", path), "modified content").unwrap();
        assert!(api::git_has_local_changes(path.clone()).unwrap());

        // Add to index
        api::git_add_all(path.clone()).unwrap();
        assert!(api::git_has_local_changes(path.clone()).unwrap()); // Still has changes (staged)

        // Commit
        api::git_commit(path.clone(), "Modified commit".to_string()).unwrap();
        assert!(!api::git_has_local_changes(path.clone()).unwrap());
    }

    #[test]
    fn test_extract_branch_name_with_head() {
        let temp_dir = TempDir::new("test_extract_branch_name_head").unwrap();
        let path = temp_dir.path().to_str().unwrap().to_string();
        api::git_init(path.clone()).unwrap();
        fs::write(format!("{}/test.txt", path), "content").unwrap();
        api::git_add_all(path.clone()).unwrap();
        api::git_commit(path.clone(), "Initial commit".to_string()).unwrap();
        let repo = git2::Repository::open(&path).unwrap();
        assert_eq!(api::extract_branch_name(&repo), "master");
    }

    #[test]
    fn test_branch_name_stripping() {
        let test_cases = vec![
            ("refs/heads/main", "main"),
            ("refs/heads/feature", "feature"),
            ("refs/remotes/origin/feature", "refs/remotes/origin/feature"),
            ("main", "main"),
            ("refs/tags/v1.0", "refs/tags/v1.0"),
        ];
        for (input, expected) in test_cases {
            let result = input.strip_prefix("refs/heads/").unwrap_or(input);
            assert_eq!(result, expected, "Failed for input: {}", input);
        }
    }
}
