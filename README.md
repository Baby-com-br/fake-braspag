# Fake Braspag

Webservice Fake da Braspag, útil para executar testes de perfomance e integração END-2-END em aplicações que dependam da Braspag, visto que a mesma não disponibiliza um sandbox.

# Instalação usando o RVM

 - Entre no diretório do projeto;
 - Execute `rvm install ruby-1.9.2` para instalar o ruby;
 - Execute `rvm use ruby-1.9.2`;
 - Instale o bundler com `gem install bundler`;
 - Instale as dependências do projeto com `bundle install`;
 - Execute `bundle exec unicorn <porta>` para iniciar o webservice.

