FROM jekyll/jekyll:stable
MAINTAINER Jordon Bedwell <jordon@envygeeks.io>
COPY copy /
RUN \
  apk --update add readline-dev libxml2-dev libxslt-dev \
    zlib-dev ruby-dev yaml-dev libffi-dev \
      build-base git && \

  cd ~ && \
  gem install --no-document octopress && \
  mkdir -p /opt/octopress && cd /opt/octopress && \
  git clone https://github.com/imathis/octopress.git . && \
  # Strip Gems that aren't necessary and also gems provided by Jekyll itself as looser depends.
  sed -ri "/^\s*gem\s+('|\")(jekyll|rdiscount|RedCloth|jekyll-sitemap)('|\")/d" Gemfile && \
  mv Gemfile Gemfile.old && grep -E '^\s*(gem|source)\s+' Gemfile.old | \
    sed -r 's/^\s+//' > Gemfile && printf 'gem "octopress"\n\n' >> \
      Gemfile && \

  rm -rf Gemfile.old && docker-helper add_gemfile_dependency $JEKYLL_VERSION && \
  docker-helper copy_default_gems_to_gemfile && \

  bundle install && bundle update && bundle clean --force && \
  apk del readline-dev libxml2-dev libxslt-dev zlib-dev \
    ruby-dev yaml-dev libffi-dev build-base git && \

  rm -rf .editorconfig .git .gitattributes .gitignore .powrc .travis.yml \
    CHANGELOG.markdown README.markdown config.rb config.ru
