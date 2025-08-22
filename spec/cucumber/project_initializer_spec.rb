# frozen_string_literal: true

require 'tmpdir'

module Cucumber
  describe ProjectInitializer, isolated_home: true do
    let(:command_line_config) { described_class.new }

    before { allow(command_line_config).to receive(:puts) }

    context 'when there are no existing files' do
      around(:example) do |example|
        dir = Dir.mktmpdir
        original_dir = Dir.pwd
        begin
          FileUtils.cd(dir)
          example.call
        ensure
          FileUtils.cd(original_dir)
          FileUtils.rm_rf(dir)
        end
      end

      it 'still creates a features directory' do
        expect(command_line_config).to receive(:puts).with('creating features')

        command_line_config.run
      end

      it 'still creates a step_definitions directory' do
        expect(command_line_config).to receive(:puts).with('creating features/step_definitions')

        command_line_config.run
      end

      it 'still creates a support directory' do
        expect(command_line_config).to receive(:puts).with('creating features/support')

        command_line_config.run
      end

      it 'still creates an env.rb file' do
        expect(command_line_config).to receive(:puts).with('creating features/support/env.rb')

        command_line_config.run
      end
    end

    context 'when there are existing files' do
      around(:example) do |example|
        dir = Dir.mktmpdir
        FileUtils.mkdir_p("#{dir}/features")
        FileUtils.mkdir_p("#{dir}/features/step_definitions")
        FileUtils.mkdir_p("#{dir}/features/support")
        FileUtils.touch("#{dir}/features/support/env.rb")
        original_dir = Dir.pwd
        begin
          FileUtils.cd(dir)
          example.call
        ensure
          FileUtils.cd(original_dir)
          FileUtils.rm_rf(dir)
        end
      end

      it 'does not create a features directory' do
        expect(command_line_config).to receive(:puts).with('features already exists')

        command_line_config.run
      end

      it 'does not create a step_definitions directory' do
        expect(command_line_config).to receive(:puts).with('features/step_definitions already exists')

        command_line_config.run
      end

      it 'does not create a support directory' do
        expect(command_line_config).to receive(:puts).with('features/support already exists')

        command_line_config.run
      end

      it 'does not create an env.rb file' do
        expect(command_line_config).to receive(:puts).with('features/support/env.rb already exists')

        command_line_config.run
      end
    end
  end
end
