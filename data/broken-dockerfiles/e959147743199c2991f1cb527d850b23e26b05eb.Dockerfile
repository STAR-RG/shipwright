FROM archlinux:latest

# Install dependencies
RUN pacman -Sy --noconfirm nodejs nginx sqlite git rustup base-devel python3 python2 npm

# Install Rust
RUN rustup default nightly

# Install task-maker-rust
RUN git clone https://aur.archlinux.org/task-maker-rust-git.git task-maker \
    && sed -i 's/(( EUID == 0 ))/false/' /usr/bin/makepkg \
    && cd /task-maker \
    && makepkg -si --noconfirm \
    && rm -rf task-maker

# Copy source file
COPY . /turingarena

# Build server
RUN cd /turingarena/server && npm ci && npm run prepare && npm run build

# Build client
RUN cd /turingarena/web && npm ci && npm run prepare && npm run build

# Create /data directory
RUN mkdir /data
WORKDIR /data

# Set entrypoint
ENTRYPOINT ["node", "/turingarena/server/build/src/cli/index.js"]

