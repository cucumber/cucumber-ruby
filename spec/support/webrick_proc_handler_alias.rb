module WEBrick
  module HTTPServlet
    class ProcHandler < AbstractServlet
      # TODO: [LH] -> Check whether a) we need this alias handler. b) whether the options offered now are correct
      # c) add link into relevant code refs with tagged versions
      # WEBrick#mount_proc only works with GET, HEAD, POST, OPTIONS by default
      alias do_PUT do_GET
    end
  end
end
