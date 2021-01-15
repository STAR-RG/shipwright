FROM opensuse:leap

RUN zypper -n install osc-plugin-install vim curl bsdtar git sudo pcre-tools
RUN curl -OkL https://download.opensuse.org/repositories/openSUSE:Tools/openSUSE_42.3/openSUSE:Tools.repo
RUN zypper -n addrepo openSUSE:Tools.repo
RUN zypper --gpg-auto-import-keys refresh
RUN zypper -n install build \
    obs-service-tar_scm \
    obs-service-verify_file \
    obs-service-obs_scm \
    obs-service-recompress \
    obs-service-download_url

