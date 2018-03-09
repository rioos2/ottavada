# Rake Tasks

This project includes several Rake tasks to automate parts of the release
process.

![Release Mgmt](https://gitlab.com/rioos/poochi/blob/master/images/masco.jpg)

## Setup

1. Install the required dependencies with Bundler:

    ```sh
    bundle install
    ```

1. Several of the tasks require API access to a GitLab instance. We store the
   endpoint and private token data in the `.env` file

## `release[version]`

This task will:

1. Create the `X-Y-stable` branches off the current `master`s respectively, if they don't yet exist.
2. Update the `VERSION` file in both `stable` branches created above.
3. Update changelogs
4. Create the `v[version]` tag, pointing to the respective
   branches created above.
5. Push all newly-created branches and tags to all remotes.

This task **will release packages as well**: Please [read muddy for build and publishing packages](https://gitlab.com/rioos/muddy)

### Examples

```sh
# Release 8.2 RC1:
bundle exec rake "release[8.2.0-rc1]"

# Release 8.2.3, but not for CE:
CE=false bundle exec rake "release[8.2.3]"

# Release 8.2.4, but not for EE:
EE=false bundle exec rake "release[8.2.4]"

# Don't push branches or tags to remotes:
TEST=true bundle exec rake "release[8.2.1]"

```
