# mirror-action
A GitHub Action for mirroring your commits to a different remote repository

### Mirror a repository with access token over HTTPS

For example, this project uses the following workflow to mirror from GitHub to GitLab

```yaml
on: [push]
  ...
      steps:
        - uses: actions/checkout@v1
        - uses: jeptechnology/mirror-action@master
          with:
            REMOTE: 'https://gitlab.com/jeptechnology/mirror-action.git'
            GIT_ACCESS_TOKEN: ${{ secrets.GIT_ACCESS_TOKEN }}
```

Be sure to set the `GIT_ACCESS_TOKEN` secret in your repo secrets settings.

**NOTE:** by default, all branches are pushed. If you want to avoid 
this behavior, set `PUSH_ALL_REFS: "false"`

You can further customize the push behavior with the `GIT_PUSH_ARGS` parameter. 
By default, this is set to `--tags --force --prune`

If something goes wrong, you can debug by setting `DEBUG: "true"`
