class CrashingHandler < DispatchRider::Handlers::Base
  def process(_params)
    raise "I crashed!"
  end
end
