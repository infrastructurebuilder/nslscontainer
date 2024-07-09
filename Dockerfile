# This is a pretty good start.  It installs ansible and poetry, but it's all done with latest fedora python
# so some things are not going to work for us.
FROM infrastructurebuilder/ansible-container:latest

ENV HOME "/root"
ENV PATH "${HOME}/.local/bin:${PATH}"
ENV SHELL "/bin/bash"
RUN dnf -y update
RUN <<ALIASES
    echo "alias ll='ls -l'" >> ${HOME}/.bashrc
    echo "alias python='python3.10'" >> ${HOME}/.bashrc
    mkdir ${HOME}/.aws
ALIASES
RUN dnf -y install git gcc-c++ python3.10-devel which pass
RUN python3.10 -m ensurepip --upgrade && python3.10 -m pip install --user pipx
RUN pipx install poetry
# ASDF
COPY tool-versions ${HOME}/.tool-versions

RUN <<ASDF
    git clone https://github.com/asdf-vm/asdf.git ${HOME}/.asdf --branch v0.14.0
    echo ". $HOME/.asdf/asdf.sh" >> ${HOME}/.bashrc
    echo ". $HOME/.asdf/completions/asdf.bash" >> ${HOME}/.bashrc
    . $HOME/.asdf/asdf.sh
    asdf plugin-add aws-vault https://github.com/karancode/asdf-aws-vault.git
    asdf install aws-vault
    echo "AWS_VAULT_BACKEND=file" >> ${HOME}/.bashrc
    #  AWS_VAULT_FILE_PASSPHRASE=password needs to be set
    asdf plugin-add pnpm
    asdf install pnpm
    pnpm setup
    . ${HOME}/.bashrc
    pnpm install -g serverless
ASDF

RUN <<SERVERLESS
    . ${HOME}/.bashrc
    serverless update
SERVERLESS

