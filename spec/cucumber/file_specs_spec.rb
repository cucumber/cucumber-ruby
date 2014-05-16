require 'cucumber/file_specs'

module Cucumber
  describe FileSpecs do
    let(:file_specs) { FileSpecs.new(["features/foo.feature:1:2:3", "features/bar.feature:4:5:6"]) }
    let(:locations) { file_specs.locations }

    it "parses locations from multiple files" do
      locations.length.should == 6
      locations.should == [
        Cucumber::Core::Ast::Location.new("features/foo.feature", 1),
        Cucumber::Core::Ast::Location.new("features/foo.feature", 2),
        Cucumber::Core::Ast::Location.new("features/foo.feature", 3),
        Cucumber::Core::Ast::Location.new("features/bar.feature", 4),
        Cucumber::Core::Ast::Location.new("features/bar.feature", 5),
        Cucumber::Core::Ast::Location.new("features/bar.feature", 6),
      ]
    end

    it "parses file names from multiple file specs" do
      files = file_specs.files

      expect(files.length).to eq 2
      expect(files).to eq [
        "features/foo.feature",
        "features/bar.feature",
      ]
    end

    context "when no line number is specified" do
      let(:file_specs) { FileSpecs.new(["features/foo.feature", "features/bar.feature:34"]) }

      it "returns a wildcard location for that file" do
        expect(locations).to eq [
          Cucumber::Core::Ast::Location.new("features/foo.feature"),
          Cucumber::Core::Ast::Location.new("features/bar.feature", 34),
        ]
      end
    end
  end
end
