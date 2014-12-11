require_relative "task_helper.rb"
load "tasks/pandoc.task"

class PandocTest < MiniTest::Test
  def test_it_generates_docx_files
    out = StringIO.new
    with_temp_dir do |d|
      PeopleAgainstSecurity::Pandoc.run!(d, out)

      out.rewind
      assert_equal "Successfully generated 2 files.\n", out.read

      names = Dir.glob("#{d}/*.docx").map do |f| Pathname.new(f).basename.to_s end

      assert_equal %w{lab-instructions.docx solution.docx}, names 
    end
  end

  def test_source_files_are_correctly_copied_to_temp
    expected = 2
    with_temp_dir do |d|
      count = Dir.entries(d).select { |f| Pathname.new(f).extname == ".md" }.count { |f| not File.directory?(f) }
      assert_equal expected, count
    end
  end

  private

  def with_temp_dir &block
    Dir.mktmpdir do |dir|
      source = Dir["doc/*"]
      source.each do |f|
        FileUtils.cp(f, dir)
      end
      yield dir
    end
  end
end
