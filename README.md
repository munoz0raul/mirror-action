# mirror-action
A GitHub Action for mirroring your commits to a different remote repository

### Mirror a repository with access token over HTTPS

For example, this project uses the following workflow to mirror from GitHub to Foundries.io Factory `containers` repo

The following .yml content should be added to the GitHub repo which you want mirrored as `.github/workflows/mirror.yml` on the default branch.

```yaml
name: Mirroring

on: [push]

jobs:
  to_foundries:
    runs-on: ubuntu-18.04
    steps:
      - uses: actions/checkout@v2
      - uses: foundriesio/mirror-action@master
        with:
          REMOTE: "https://source.foundries.io/factories/<FACTORY-NAME>/containers.git"
          GIT_ACCESS_TOKEN: ${{ secrets.GIT_ACCESS_TOKEN }}
          PUSH_ALL_REFS: "true"
```

**NOTE:** by default, all branches are pushed. If you want to avoid 
this behavior, set `PUSH_ALL_REFS: "false"` and `GITHUB_REF: "<branch>"` to 
select the desired branch. 

You can further customize the push behavior with the `GIT_PUSH_ARGS` parameter. 
By default, this is set to `--tags --force`

If something goes wrong, you can debug by setting `DEBUG: "true"`

Be sure to set the `GIT_ACCESS_TOKEN` secret in the same repo's secrets settings:

First you must generate a scoped FIO_TOKEN for accessing source code:
- Go to: https://app.foundries.io/settings/tokens/
- Under "Api Tokens" click on the "+ New Token" button and create a scoped token:
- Description: Container Mirror Token
- Expiration: optionally set an expiration for the token
- Click "Next"
- Select "Use for source code access" and this will add `source:read-update` to list of token scopes.
- Click on "Generate" and copy the token to your copy buffer.  This is your `<FIO_TOKEN>` value.

Convert this value to a base64 string (accepted by GitHub as a secret):
- `echo -n <FIO_TOKEN> | base64 -w0`
- Save the output of this command to your copy buffer.  This is your `<BASE64_FIO_TOKEN>` value.
- NOTES: Your value should end with "==" and the output won't have a carriage return added.

To set the `GIT_ACCESS_TOKEN` base64-encoded secret in the repo you wish to mirror:
- Go to your GitHub repo
- Click on "Settings"
- Click on "Secrets"
- Click on "New repository secret"
- Name: `GIT_ACCESS_TOKEN`
- Value: Paste the `<BASE64_FIO_TOKEN>` value here
- Click on "Add secret"
