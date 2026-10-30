# frozen_string_literal: true

require 'fileutils'
require 'tmpdir'
require 'open3'
require 'rbconfig'

module DataScripts
  module_function

  def repo_root
    File.expand_path('../..', __dir__)
  end

  def scripts_dir
    File.join(repo_root, 'data', 'scripts')
  end

  def sandbox
    @sandbox ||= Dir.mktmpdir('doge_data_scripts')
  end

  def reset_sandbox!
    @sandbox = Dir.mktmpdir('doge_data_scripts')
    FileUtils.mkdir_p(File.join(@sandbox, 'data', 'scripts'))
    FileUtils.mkdir_p(File.join(@sandbox, 'data', 'raw_data'))
    @sandbox
  end

  def copy_script(name)
    dst = File.join(sandbox, 'data', 'scripts', name)
    FileUtils.cp(File.join(scripts_dir, name), dst)
    dst
  end

  def write_raw(rel_path, content)
    path = File.join(sandbox, 'data', 'raw_data', rel_path)
    FileUtils.mkdir_p(File.dirname(path))
    File.write(path, content)
    path
  end

  def run_script(path)
    run_ruby(path)
  end

  def run_ruby(*)
    out, err, status = Open3.capture3(RbConfig.ruby, *)
    { status: status, out: out, err: err }
  end

  def sandbox_db
    File.join(sandbox, 'data', 'doge.db')
  end

  def sandbox_data_path(rel_path = nil)
    raw = rel_path ? File.join('data', 'raw_data', rel_path) : File.join('data', 'raw_data')
    File.join(sandbox, raw)
  end

  def copy_models!
    dst = File.join(sandbox, 'models')
    FileUtils.cp_r(File.join(repo_root, 'models'), dst)
    dst
  end
end
