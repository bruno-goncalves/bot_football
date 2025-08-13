# syntax=docker/dockerfile:1
# check=error=true

# Make sure RUBY_VERSION matches .ruby-version
ARG RUBY_VERSION=3.4.1
FROM docker.io/library/ruby:${RUBY_VERSION}-slim AS base

# Rails app lives here
WORKDIR /rails

# Install base packages
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y curl libjemalloc2 libvips postgresql-client && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

# Set production env
ENV RAILS_ENV=production \
    BUNDLE_DEPLOYMENT=1 \
    BUNDLE_PATH=/usr/local/bundle \
    BUNDLE_WITHOUT=development

# ------------------------------------------------------------------------------
# Build stage
# ------------------------------------------------------------------------------
FROM base AS build

# Build deps
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y build-essential git libpq-dev libyaml-dev pkg-config && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

# Bundler
COPY Gemfile Gemfile.lock ./
RUN bundle install && \
    rm -rf ~/*/.bundle* "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git && \
    bundle exec bootsnap precompile --gemfile

# App code
COPY . .

# Bootsnap app precompile
RUN bundle exec bootsnap precompile app/ lib/

# Precompile assets (Propshaft + Tailwind). Use dummy secret to avoid requiring RAILS_MASTER_KEY.
# Ensure tailwind.config.js content globs are correct so purge doesn't remove styles.
RUN SECRET_KEY_BASE_DUMMY=1 bundle exec rails assets:precompile

# ------------------------------------------------------------------------------
# Final runtime image
# ------------------------------------------------------------------------------
FROM base

# Copy built gems and app
COPY --from=build "${BUNDLE_PATH}" "${BUNDLE_PATH}"
COPY --from=build /rails /rails

# Explicitly ensure precompiled builds are present in final image
# (some setups accidentally exclude them; this line is defensive)
COPY --from=build /rails/app/assets/builds /rails/app/assets/builds

# Non-root user
RUN groupadd --system --gid 1000 rails && \
    useradd rails --uid 1000 --gid 1000 --create-home --shell /bin/bash && \
    chown -R rails:rails db log storage tmp
USER 1000:1000

# Entrypoint prepares db
ENTRYPOINT ["/rails/bin/docker-entrypoint"]

# Kamal-proxy/Traefik will route to the app’s internal port 3000; we do not publish 80/443 here.
EXPOSE 3000

# Start server (Thruster + Rails)
CMD ["./bin/thrust", "./bin/rails", "server", "-p", "3000", "-b", "0.0.0.0"]
