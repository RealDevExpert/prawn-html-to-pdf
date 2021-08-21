# frozen_string_literal: true

RSpec.describe PrawnHtml do
  describe '.append_html' do
    subject(:append_html) { described_class.append_html(pdf, html) }

    let(:pdf) { instance_double(Prawn::Document) }
    let(:html) { '<div>some html</div>' }
    let(:html_parser) { instance_double(PrawnHtml::HtmlParser, process: true) }
    let(:renderer) { instance_double(PrawnHtml::DocumentRenderer) }

    before do
      allow(PrawnHtml::DocumentRenderer).to receive(:new).and_return(renderer)
      allow(PrawnHtml::HtmlParser).to receive(:new).and_return(html_parser)
    end

    it 'creates an instance of PrawnHtml::HtmlParser and call process', :aggregate_failures do
      append_html
      expect(PrawnHtml::DocumentRenderer).to have_received(:new).with(pdf)
      expect(PrawnHtml::HtmlParser).to have_received(:new).with(renderer)
      expect(html_parser).to have_received(:process).with(html)
    end
  end
end
