# Phase 4 - Git Branching, Pull Requests & Merge Conflicts

## Branch-based Workflow
Practiced the standard team workflow instead of committing directly to
`main`:
```bash
git checkout -b feature/log-rotation-script
# ...edit, commit...
git push -u origin feature/log-rotation-script
```
Opened a Pull Request on GitHub, reviewed the diff in "Files changed", and
merged it into `main` , then synced the local `main` with `git pull`.

## Reproducing and Resolving a Merge Conflict
Deliberately created a conflict by branching twice from the same point in
`main` and editing the same line in the `README.md` differently in each
branch.

After merging the first branch cleanly, the second branch's `git pull
origin main` failed with:
```
Automatic merge failed; fix conflicts and then commit the result.
```

Git marked the conflicting section like this:
```
<<<<<<< HEAD
(local branch version)
=======
(incoming main version)
>>>>>>> main
```

Resolved manually by choosing the intended content, removing the conflict
markers entirely, then:
```bash
git add README.md
git commit -m "Resolve merge conflict: keep version B title"
git push
```

**Key takeaway:** a merge conflict happens when Git can't automatically
reconcile two changes to the same lines resolution means manually
deciding the final content and removing the `<<<<<<<`/`=======`/`>>>>>>>`
markers before committing.