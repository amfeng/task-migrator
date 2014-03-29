# task-migrator

## Setup

Set environment variables for `ASANA_API_KEY` and `PHAB_HOST`.

    export ASANA_API_KEY=<KEY>
    export PHAB_HOST=https://secure.phabricator.org

To communicate with Phabricator, you'll need to follow [these steps](https://github.com/amfeng/phabricator-ruby) to authenticate yourself with Conduit.

## Usage

Pass Asana project ID as the first command line argument:

    ruby asana_to_phabricator.rb <ASANA PROJECT ID>

## TODO:

  - Fall down gracefully when a Project doesn't exist
  - Proper error handling of things
