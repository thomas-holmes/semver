require 'simplecov'
SimpleCov.start
require 'sem_ver'
require 'rspec/collection_matchers'

RSpec::Matchers.define :be_a_version_equivalent_to do |hash|
  match do |version|
    version.major ==  (hash[:major] || 0)  &&
    version.minor ==  (hash[:minor] || 0)  &&
    version.patch ==  (hash[:patch] || 0)  &&
    version.pre   == [(hash[:pre]   || [])].flat_map { |i| i }.map(&:to_s) &&
    version.build == [(hash[:build] || [])].flat_map { |i| i }.map(&:to_s)
  end
end

module SemVer
  shared_examples 'SemanticVersion creation' do
    before(:each) { @version_hash = { :major => 1, :minor => 2, :patch => 3 } }
    context 'simple version' do
      it 'can be created' do
        expect(version).to be_a_version_equivalent_to(@version_hash)
      end

      context 'error conditions' do
        specify 'negative major version raises' do
          @version_hash[:major] = -1
          expect { version }.to raise_error(InvalidSemanticVersion)
        end

        specify 'negative minor version raises' do
          @version_hash[:minor] = -1
          expect { version }.to raise_error(InvalidSemanticVersion)
        end

        specify 'negative patch version raises' do
          @version_hash[:patch] = -1
          expect { version }.to raise_error(InvalidSemanticVersion)
        end
      end
    end

    context 'pre-release versions' do
      specify 'when no pre-release values are supplied #pre is an empty array' do
        expect(version.pre). to eq []
      end

      it 'can be made with a single string tag' do
        @version_hash[:pre] = 'beta1'
        expect(version).to have(1).pre
        expect(version.pre).to eq ['beta1']
      end

      it 'can be made with an array of tags' do
        @version_hash[:pre] = ['beta']
        expect(version).to have(1).pre
        expect(version.pre).to eq ['beta']
      end

      it 'can be made with multiple tags' do
        @version_hash[:pre] = ['beta1', 'beta2']
        expect(version).to have(2).pre
        expect(version.pre).to eq ['beta1', 'beta2']
      end

      specify 'pre tags end up as string values' do
        @version_hash[:pre] = ['beta1', 2]
        expect(version).to have(2).pre
        expect(version.pre).to eq ['beta1', '2']
      end

      specify 'empty pre tags are disregarded' do
        @version_hash[:pre] = ['beta1', '']
        expect(version).to have(1).pre
        expect(version.pre).to eq ['beta1']
      end

      context 'error conditions' do
        specify 'leading 0 is invalid' do
          @version_hash[:pre] = '0123'
          expect { version }.to raise_error(InvalidSemanticVersion)
        end

        specify 'leading special character is invalid' do
          @version_hash[:pre] = '*aaa'
          expect { version }.to raise_error(InvalidSemanticVersion)
        end

        specify 'symbols other than dash are invalid' do
          @version_hash[:pre] = ['sdk&d']
          expect { version }.to raise_error(InvalidSemanticVersion)
        end
      end
    end

    context 'build labels' do
      specify 'when no build metadata is supplied #build is an empty array' do
        expect(version.build). to eq []
      end

      it 'can be made with a single string build tag' do
        @version_hash[:build] = 'exp'
        expect(version).to have(1).build
        expect(version.build).to eq ['exp']
      end

      it 'can be made with an array of build tags' do
        @version_hash[:build] = ['exp']
        expect(version).to have(1).build
        expect(version.build).to eq ['exp']
      end

      it 'can be made with multiple build tags' do
        @version_hash[:build] = ['exp', '20141205']
        expect(version).to have(2).build
        expect(version.build).to eq ['exp', '20141205']
      end

      it 'build tags end up as string values' do
        @version_hash[:build] = ['exp', 2]
        expect(version).to have(2).build
        expect(version.build).to eq ['exp', '2']
      end

      it 'empty build tags are disregarded' do
        @version_hash[:build] = ['exp', '']
        expect(version).to have(1).build
        expect(version.build).to eq ['exp']
      end

      context 'error conditions' do
        it 'raises on invalid characters' do
          @version_hash[:build] = ['dafj^']
          expect { version }.to raise_error(InvalidSemanticVersion)
        end
      end
    end

    context 'pre and build labels' do
      specify 'one of each' do
        @version_hash.merge!({ :pre => 'pre', :build => '333' })
        expect(version).to be_a_version_equivalent_to(@version_hash)
      end

      specify 'multiple pre-releae tags' do
        @version_hash.merge!({ :pre => ['pre', 'aaa'], :build => '333'})
        expect(version).to be_a_version_equivalent_to(@version_hash)
      end

      specify 'multiple build tags' do
        @version_hash.merge!({ :pre => 'pre', :build => ['333', 'xyz']})
        expect(version).to be_a_version_equivalent_to(@version_hash)
      end
    end
  end

  describe "SemanticVersion" do
    context 'constructor' do
      let(:version) { SemanticVersion.new(@version_hash) }
      include_examples 'SemanticVersion creation'
    end

    context 'parser' do
      let(:version) { SemanticVersion.parse(version_string) }
      let(:version_string) { hash_to_string(@version_hash) }
      include_examples 'SemanticVersion creation'
    end

    context 'comparison' do
      let(:version_2) { SemanticVersion.parse('2.0.0') }
      let(:version_3) { SemanticVersion.parse('3.0.0') }
      let(:version_3_1) { SemanticVersion.parse('3.1.0') }
      let(:version_3_0_1) { SemanticVersion.parse('3.0.1') }

      context '#==' do
        specify '3.0.0 is equal to 3.0.0' do
          version = SemanticVersion.parse('3.0.0')
          expect(version).to eq version_3
        end

        specify '3.0.0-pre1 is equal to 3.0.0-pre1' do
          expect(SemanticVersion.parse('3.0.0-pre1')).to eq SemanticVersion.parse('3.0.0-pre1')
        end

        specify '3.0.0-x.Y is equal to 3.0.0-x.Y' do
          expect(SemanticVersion.parse('3.0.0-x.Y')).to eq SemanticVersion.parse('3.0.0-x.Y')
        end
      end

      context '#>' do
        specify '3.0.0 is greater than 2.0.0' do
          expect(version_3).to be > version_2
        end

        specify '3.1.0 is greater than 3.0.0' do
          expect(version_3_1).to be > version_3
        end

        specify '3.0.1 is greater than 3.0.0' do
          expect(version_3_0_1).to be > version_3
        end

        specify '3.0.0 is greater than 3.0.0-pre1' do
          version = SemanticVersion.parse('3.0.0-pre1')
          expect(version_3).to be > version
        end
      end

      context '#>=' do
        specify '3.0.0 is greater than or equal to 3.0.0' do
          version = SemanticVersion.parse('3.0.0')
          expect(version).to be >= version_3
        end

        specify '3.0.0 is greater than or equal to 2.0.0' do
          expect(version_3).to be >= version_2
        end

        specify '3.1.0 is greater than or equal to 3.0.0' do
          expect(version_3_1).to be >= version_3
        end

        specify '3.0.1 is greater than or equal to 3.0.0' do
          expect(version_3_0_1).to be >= version_3
        end

        specify '3.0.0 is greater than or equal 3.0.0-pre1' do
          version = SemanticVersion.parse('3.0.0-pre1')
          expect(version_3).to be >= version
        end
      end

      context '#<' do
        specify '2.0.0 is less than 3.0.0' do
          expect(version_2).to be < version_3
        end

        specify '3.0.0 is less than 3.1.0' do
          expect(version_3).to be < version_3_1
        end

        specify '3.0.0 is less than 3.0.1' do
          expect(version_3).to be < version_3_0_1
        end

        specify '3.0.0-pre1 is less than 3.0.0' do
          version = SemanticVersion.parse('3.0.0-pre1')
          expect(version).to be < version_3
        end
      end

      context '#<=' do
        specify '3.0.0 is less than or equal to 3.0.0' do
          version = SemanticVersion.parse('3.0.0')
          expect(version).to be <= version_3
        end

        specify '2.0.0 is less than or equal to 3.0.0' do
          expect(version_2).to be <= version_3
        end

        specify '3.0.0 is less than or equal to 3.1.0' do
          expect(version_3).to be <= version_3_1
        end

        specify '3.0.0 is less than or equal to 3.0.1' do
          expect(version_3).to be <= version_3_0_1
        end

        specify '3.0.0-pre1 is less than or equal to 3.0.0' do
          version = SemanticVersion.parse('3.0.0-pre1')
          expect(version).to be <= version_3
        end
      end

      context 'from specs' do
        LESS_THAN_REFERENCE = "1.0.0-alpha 1.0.0-alpha.1 1.0.0-alpha.beta 1.0.0-beta 1.0.0-beta.2 1.0.0-beta.11 1.0.0-rc.1 1.0.0"
        versions = LESS_THAN_REFERENCE.split(' ').map { |v| SemanticVersion.parse(v) }
        pairs = versions.drop(1).each_with_index.map { |o, i| [versions[i - 1], o] }
        pairs.each do |l, r|
          xspecify "#{l} to be less than #{r}" do
            expect(l).to be < r
          end
        end
      end

      context '#to_s' do
        ['3.0.0', '3.0.0-beta1', '3.0.0-beta1.8', '3.1.2+12345',
         '3.1.2+123.456', '3.1.2-beta1.pre+1111', '3.1.2-beta+111.443'].each do |v|
          it(v) { expect(SemanticVersion.parse(v).to_s).to eq v }
        end
      end
    end
  end
end

def hash_to_string(hash)
  version = "#{hash[:major]}.#{hash[:minor]}.#{hash[:patch]}"
  pre = hash[:pre]
  if String === pre
    version = "#{version}-#{pre}"
  elsif Enumerable === pre && !pre.empty?
    version = "#{version}-#{pre.join('.')}"
  end

  build = hash[:build]
  if String === build
    version = "#{version}+#{build}"
  elsif Enumerable === build && !build.empty?
    version = "#{version}+#{build.join('.')}"
  end

  version
end
