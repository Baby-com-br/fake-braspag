module FakeBraspag
  class Toggler < Sinatra::Base
    get '/:feature/disable' do
      if ResponseToggler.enabled?(params[:feature])
        ResponseToggler.disable(params[:feature])

        halt 200
      else
        halt 304
      end
    end

    get '/:feature/enable' do
      if !ResponseToggler.enabled?(params[:feature])
        ResponseToggler.enable(params[:feature])

        halt 200
      else
        halt 304
      end
    end
  end
end
