module Inquisition
  class ExternalChecks < Checks

    def checks
      {
        :disk_size => lambda { |target| file_system(target['device'])[:kb_size] },
        :disk_percent_used => lambda {|target| file_system(target['device'])[:percent_used] }
      }
    end
  end
end
