# encoding: utf-8
# frozen_string_literal: true

require_relative '../../test_helper'
require 'pagy/extras/overflow'

SimpleCov.command_name 'overflow' if ENV['RUN_SIMPLECOV']

describe Pagy do

  let(:vars) {{ page: 100, count: 103, items: 10, size: [3, 2, 2, 3] }}
  let(:countless_vars) {{ page: 100, items: 10 }}

  before do
    @pagy = Pagy.new(vars)
    @pagy_countless = Pagy::Countless.new(countless_vars)
    @pagy_countless.finalize(0)
  end

  describe "variables" do

    it 'has vars defaults' do
      Pagy::VARS[:overflow].must_equal :empty_page  # default for countless
    end

  end

  describe "#overflow?" do

    it 'must be overflow?'  do
      @pagy.must_be :overflow?
      @pagy_countless.must_be :overflow?
      Pagy.new(vars.merge(page:2)).wont_be :overflow?
    end

  end


  describe "#initialize" do

    it 'works in :last_page mode' do
      pagy = Pagy.new(vars.merge(overflow: :last_page))
      pagy.must_be_instance_of Pagy
      pagy.page.must_equal pagy.last
      pagy.vars[:page].must_equal 100
      pagy.offset.must_equal 100
      pagy.items.must_equal 3
      pagy.from.must_equal 101
      pagy.to.must_equal 103
      pagy.prev.must_equal 10
    end

    it 'raises OverflowError in :exception mode' do
      proc { Pagy.new(vars.merge(overflow: :exception)) }.must_raise Pagy::OverflowError
      proc { Pagy::Countless.new(countless_vars.merge(overflow: :exception)).finalize(0) }.must_raise Pagy::OverflowError
    end

    it 'works in :empty_page mode' do
      pagy = Pagy.new(vars.merge(overflow: :empty_page))
      pagy.page.must_equal 100
      pagy.offset.must_equal 0
      pagy.items.must_equal 0
      pagy.from.must_equal 0
      pagy.to.must_equal 0
      pagy.prev.must_equal pagy.last
    end

    it 'raises Pagy::VariableError' do
      proc { Pagy.new(vars.merge(overflow: :unknown)) }.must_raise Pagy::VariableError
      proc { Pagy::Countless.new(countless_vars.merge(overflow: :unknown)).finalize(0) }.must_raise Pagy::VariableError
    end

  end

  describe "#series singleton for :empty_page mode" do

    it 'computes series for last page' do
      pagy = Pagy.new(vars.merge(overflow: :empty_page))
      series = pagy.series
      series.must_equal [1, 2, 3, :gap, 9, 10, 11]
      pagy.page.must_equal 100
    end

    it 'computes empty series' do
      series = @pagy_countless.series
      series.must_equal []
      @pagy_countless.page.must_equal 100
    end

  end

end
