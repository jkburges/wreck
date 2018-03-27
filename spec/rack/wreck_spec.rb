require_relative "../spec_helper"

require_relative "../../lib/rack/wreck"
require_relative "../../lib/rack/wreck/delay"
require_relative "../../lib/rack/wreck/override"

describe "wreck" do
  it "configures overrides with DSL" do
    Rack::Wreck.configure do
      override "/", chance: 0.1, status: 500
      override /widget/, chance: 0.05, status: 403, body: "Nice try!"
      delay "/slow", 3.seconds
    end

    assert_equal Rack::Wreck::Override.new("/", chance: 0.1, status: 500), Rack::Wreck.overrides[0]
    assert_equal Rack::Wreck::Override.new(/widget/, chance: 0.05, status: 403, body: "Nice try!"), Rack::Wreck.overrides[1]
    assert_equal Rack::Wreck::Delay.new("/slow", 3.seconds), Rack::Wreck.delays[0]
  end

  it "calls override" do
    class TestWreck < Rack::Wreck
      def override(env)
        OpenStruct.new(call: "override call")
      end

      def app_call(env)
        "app call"
      end
    end

    app = Object.new
    env = Object.new

    wreck = TestWreck.new (app)
    assert_equal "override call", wreck.call(env)
  end

  it "calls app" do
    class TestWreck < Rack::Wreck
      def override(env)
        nil
      end

      def app_call(env)
        "app call"
      end
    end

    app = Object.new
    env = Object.new

    wreck = TestWreck.new (app)
    assert_equal "app call", wreck.call(env)
  end

  it "executes matched delay" do

  end
end
