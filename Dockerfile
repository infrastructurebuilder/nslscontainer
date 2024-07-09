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
RUN dnf -y install git gcc-c++ python3.10-devel which pass dos2unix
RUN python3.10 -m ensurepip --upgrade && python3.10 -m pip install --user pipx
RUN pipx install poetry
# ENV variables
RUN <<EXPORTS
    echo "export PATH=$PATH:/usr/lib/node_modules/npm/bin" >> ${HOME}/.bashrc
    echo "export SDP_SETTINGS_S3_URL=\"s3://config-ue2-dev-20230823021117337900000001/sdp.env\"" >> ${HOME}/.bashrc
    echo "export SDP_DATABASE_HOST=\"3.135.29.218\"" >> ${HOME}/.bashrc
    echo "export SDP_DATABASE_PORT=\"5432\"" >> ${HOME}/.bashrc
    echo "AWS_VAULT_BACKEND=file" >> ${HOME}/.bashrc
EXPORTS
# ASDF
COPY tool-versions ${HOME}/.tool-versions
COPY config ${HOME}/.aws/config
COPY sg_setup.sh ${HOME}/.local/bin/sg_setup.sh
RUN dos2unix ${HOME}/.aws/config ${HOME}/.bashrc ${HOME}/.tool-versions ${HOME}/.local/bin/sg_setup.sh

RUN <<ASDF
    git clone https://github.com/asdf-vm/asdf.git ${HOME}/.asdf --branch v0.14.0
    echo ". $HOME/.asdf/asdf.sh" >> ${HOME}/.bashrc
    echo ". $HOME/.asdf/completions/asdf.bash" >> ${HOME}/.bashrc
    . ${HOME}/.asdf/asdf.sh
    asdf plugin-add aws-vault https://github.com/karancode/asdf-aws-vault.git    
    asdf install aws-vault
    # export AWS_VAULT_FILE_PASSPHRASE=somepassword needs to be set
    asdf plugin-add nodejs
    asdf install nodejs
    asdf plugin-add pnpm
    asdf install pnpm
    pnpm setup
    . ${HOME}/.bashrc
    pnpm install -g serverless
    serverless update
ASDF
