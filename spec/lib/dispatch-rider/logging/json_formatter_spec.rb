require 'spec_helper'

describe DispatchRider::Logging::JsonFormatter do
  let(:message) { DispatchRider::Message.new(subject: 'test', body: {key: 'value'}) }
  let(:guid) { 123 }
  let(:object_id) { 456 }
  let(:exception) { StandardError.new }
  let(:reason) { "Stop reason" }

  before do
    allow(message).to receive(:guid).and_return(guid)
    allow(message).to receive(:object_id).and_return(object_id)
  end

  let(:result_object) do
    {
      "object_id" => "456",
      "subject" => "test",
      "guid" => "123",
      "body" => {
        "key" => "value"
      },
    }
  end
  let(:result_exception) do
    {
      "expection" => {
        "class" => "StandardError",
        "message" => "StandardError"
      }
    }
  end

  context "format_error_handler_fail" do
    let(:formatted_message) { result_object.merge("message" => "Failed error handling").merge(result_exception) }
    let(:result_message) { JSON.parse subject.format_error_handler_fail(message, exception) }

    example { expect(result_message).to eq(formatted_message) }
  end

  context "format_got_stop" do
    let(:formatted_message) { result_object.merge("message" => "Got stop", "reason" => reason) }
    let(:result_message) { JSON.parse subject.format_got_stop(message, reason) }

    example { expect(result_message).to eq(formatted_message) }
  end

  context "format_handling" do
    context "start" do
      let(:formatted_message) { result_object.merge("message" => "Starting execution") }
      let(:result_message) { JSON.parse subject.format_handling(:start, message) }

      example { expect(result_message).to eq(formatted_message) }
    end

    context "success" do
      let(:formatted_message) { result_object.merge("message" => "Succeeded execution") }
      let(:result_message) { JSON.parse subject.format_handling(:success, message) }

      example { expect(result_message).to eq(formatted_message) }
    end

    context "complete" do
      let(:formatted_message) { result_object.merge("message" => "Completed execution") }
      let(:result_message) { JSON.parse subject.format_handling(:complete, message) }

      example { expect(result_message).to eq(formatted_message) }
    end

    context "fail" do
      let(:formatted_message) { result_object.merge("message" => "Failed execution").merge(result_exception) }
      let(:result_message) { JSON.parse subject.format_handling(:fail, message, exception) }

      example { expect(formatted_message).to eq(formatted_message) }
    end
  end
end
