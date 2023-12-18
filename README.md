# jumpseat

## About

jumpseat is a desk reservation web application build in Ruby on Rails.
jumpseat allows to manage:

  - tenants
  - locations
  - floors
  - rooms
  - desks
  - limitations
  - reservations
  - users

## Images

when it's done =)

## Configuration

To run jumpseat you need to fulfill the following requirements first:

- provide a postgres database
- provide a redis cache
- provide a sidekiq scheduler

The following options can/must be set through environment variables:

| Variable  | Default | Required | Description |
| --------- |:-------:|:----------:|--------------|
| RAILS_ENV | "development" | yes | Which environment to use (development, test, production) |
| RAILS_HOSTS | nil | yes | Which host names should jumpseat listen to (DNS rebind protection, comma seperated list) |
| SECRET_KEY_BASE | nil | yes | a string that is used as base for encryption |
| DATABASE_URL | nil | yes | url address to your postgres (e.g. postgres://user:password@localhost:5432) |
| REDISCLOUD_URL | nil | yes | url to your redis cache (e.g. redis://localhost:6379/0) |
| JUMPSEAT_RACKATTACK_REQIP_LIMIT | 1000 | yes | rack-attack rate limiting request/ip, e.g. 1000 |
| JUMPSEAT_RACKATTACK_REQIP_LOGIN_LIMIT | 50 | yes | rack-attack rate limiting request/ip at POST /users/sign_in, e.g. 50 |
| JUMPSEAT_RACKATTACK_REQIP_SAFE_IP | nil | no | rack-attack safe ip, excluded from throttling etc. can also be defined as a subnet, e.g. 192.168.0.0/16 |
| ACTIVE_RECORD_ENCRYPTION_PRIMARY_KEY | nil | yes | active record encryption primary key |
| ACTIVE_RECORD_ENCRYPTION_DETERMINISTIC_KEY | nil | yes | active record encryption deterministic key |
| ACTIVE_RECORD_ENCRYPTION_KEY_DERIVATION_SALT | nil | yes | active record encryption key derivation salt |

See [Active Record Encryption](https://guides.rubyonrails.org/active_record_encryption.html) for details on the last three.
The rack-attack configurations are pretty specific to your environment, so handle with care (too small and you might block yourself).

## Startup
We provide two Procfiles.

- Procfile: default procfile to start jumpseat with sidekiq.
- Procfile.dev: for local development purposes. This procfile will boot up needed services (postgres, redis, sidekiq) and jumpseat itself.

Alternatively you can just use one of the provided container images and link to your postgres and redis.
Please check the docker-compose.yml as an example.

## Development
If you wish to contribute or just poke around, please fulfill the requirements first:

- have Ruby 3.2.2 installed
- have podman and podman-compose installed

There are two different methods to develop jumpseat locally:

### Option 1: use bin/dev

This method relies on you having the tools installed locally. So run:
```bash
bundle install
```
first to install the needed dependencies. After that, you can run
```bash
podman-compose down && sleep 2 && bin/dev
```
to boot up jumpseat. bin/dev uses foreman to start the Procfile.dev procfile. This will automatically spawn needed services using podman and
call bin/docker-entrypoint (just like in the container). That entrypoint
will run bin/rails db:prepare which will migrate the development database and seed it with test data.

Once you stop foreman, the services will be shut down. This method resets your redis cache and db.

### Option 2: use podman-compose

With this option, there is no need for ruby tools installed locally. Just run:
```bash
podman-compose up
```
and wait for the services to start. With this option, if you are in need to use bin/rails (e.g. bin/rails console), you need to do this within the container:
```bash
podman exec -it jumpseat_app_1 bin/rails console
```
This method does not allow hot reloading, so any change you make, enforces you to restart the compose stack. This option will reset your DB and redis as well on boot.

### local config
Both options require you to set the appropriate environment variables.
jumpseat looks for a .env file in the root folder on boot. For the second option, you should put your configuration into .env.container which will be loaded automatically by the compose stack.

If you like to keep your DB contents after a restart, remove the comments for volumes in docker-compose.yml. Be aware: db/seeds.rb is not idempotent for the Development environment.

# Todo
- draw room
  - date picker
  - room picker
  - positions
  - status of desk (gray = limited, red = reserved, green = available)
  - click on green desk -> create reservation path with params
  - click on red desk -> edit reservation path if reservation.user_id == current_user.id
- (bulk delete reservations)
- (personal api token)
- omniauthable
