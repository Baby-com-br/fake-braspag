require 'spec_helper'

describe FakeBraspag::Application do
  it 'responds to' do
    post '/webservices/pagador/Pagador.asmx/Capture'

    expect(last_response.body).to eq "<em>hi</em>\n"
  end
end
