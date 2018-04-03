# Rake Tasks

This project includes several Rake tasks to automate parts of the release
process.

![Release Bot](https://gitlab.com/rioos/ottavada/raw/2-0-stable/images/ottavada.png)

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

This task **will release packages as well**: Please [read poochi for build and publishing packages](https://gitlab.com/rioos/poochi.git)

### Examples

```sh
# Release 2.0 RC1:
bundle exec rake "release[2.0.0-rc1]"

# Release 2.0.0:
bundle exec rake "release[2.0.0]"

# Release 2.1.0:
bundle exec rake "release[2.1.0]"

# Don't push branches or tags to remotes:
# (or) cp .env_test .env
TEST=true bundle exec rake "release[2.0.0.rc1]"

```
