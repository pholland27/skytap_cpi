require 'json'
module Bosh::SkytapCloud

  class Cloud < Bosh::Cloud
        ##
    # Cloud initialization
    #
    # @param [Hash] options cloud options
    def initialize(options)
      @options = options.dup

      validate_options

      @logger = Bosh::Clouds::Config.logger

      @agent_properties = @options['agent'] || {}
      @skytap_properties = @options['skytap']

      @client = Client(@skytap_properties['site'], @skytap_properties['username'], @skytap_properties['password'])
    end

    def set_registry(entity_id, entity_type, registry)
      # TODO: figure out how to convert registry dictionary to proper notes json
      @client.post("/#{entity_type}/#{entity_id}/notes", body=>"")
    end

    def get_registry(entity_id)
      ret = @client.get("/#{entity_type}/#{entity_id}/notes")
      ret.body do |note|
        return JSON.parse(note['text'][9..-1]) if note['text'][0..8] == 'BOSHREG:'
      end
    end

    ##
    # Creates a stemcell
    #
    # @param [String] image_path path to an opaque blob containing the stemcell image
    # @param [Hash] cloud_properties properties required for creating this template
    #               specific to a CPI
    # @return [String] opaque id later used by {#create_vm} and {#delete_stemcell}
    def create_stemcell(image_path, cloud_properties)
      not_implemented(:create_stemcell)
    end

    ##
    # Deletes a stemcell
    #
    # @param [String] stemcell stemcell id that was once returned by {#create_stemcell}
    # @return nil
    def delete_stemcell(stemcell_id)
      not_implemented(:delete_stemcell)
    end

    ##
    # Creates a VM - creates (and powers on) a VM from a stemcell with the proper resources
    # and on the specified network. When disk locality is present the VM will be placed near
    # the provided disk so it won't have to move when the disk is attached later.
    #
    # Sample networking config:
    #  {"network_a" =>
    #    {
    #      "netmask"          => "255.255.248.0",
    #      "ip"               => "172.30.41.40",
    #      "gateway"          => "172.30.40.1",
    #      "dns"              => ["172.30.22.153", "172.30.22.154"],
    #      "cloud_properties" => {"name" => "VLAN444"}
    #    }
    #  }
    #
    # Sample resource pool config (CPI specific):
    #  {
    #    "ram"  => 512,
    #    "disk" => 512,
    #    "cpu"  => 1
    #  }
    # or similar for EC2:
    #  {"name" => "m1.small"}
    #
    # @param [String] agent_id UUID for the agent that will be used later on by the director
    #                 to locate and talk to the agent
    # @param [String] stemcell stemcell id that was once returned by {#create_stemcell}
    # @param [Hash] resource_pool cloud specific properties describing the resources needed
    #               for this VM
    # @param [Hash] networks list of networks and their settings needed for this VM
    # @param [optional, String, Array] disk_locality disk id(s) if known of the disk(s) that will be
    #                                    attached to this vm
    # @param [optional, Hash] env environment that will be passed to this vm
    # @return [String] opaque id later used by {#configure_networks}, {#attach_disk},
    #                  {#detach_disk}, and {#delete_vm}
    def create_vm(agent_id, stemcell_id, resource_pool,
                  networks, disk_locality = nil, env = nil)
      with_thread_name("create_vm(#{agent_id}, ...)") do
        
        configuration_id = resource_pool['cloud_properties']['configuration_id']

        if configuration_id.nil? do
            ret = @client.post("/configurations", {:template_id => stemcell_id})
            resource_pool['cloud_properties']['configuration_id'] = ret.body['configuration_id']
        else
            @client.post("/configurations/#{configuration_id}", {:template_id => stemcell_id})
        end
      end
    end

    ##
    # Deletes a VM
    #
    # @param [String] vm vm id that was once returned by {#create_vm}
    # @return nil
    def delete_vm(vm_id)
      not_implemented(:delete_vm)
    end

    ##
    # Reboots a VM
    #
    # @param [String] vm vm id that was once returned by {#create_vm}
    # @param [Optional, Hash] CPI specific options (e.g hard/soft reboot)
    # @return nil
    def reboot_vm(vm_id)
      not_implemented(:reboot_vm)
    end

    ##
    # Configures networking an existing VM.
    #
    # @param [String] vm vm id that was once returned by {#create_vm}
    # @param [Hash] networks list of networks and their settings needed for this VM,
    #               same as the networks argument in {#create_vm}
    # @return nil
    def configure_networks(vm_id, networks)
      not_implemented(:configure_networks)
    end

    ##
    # Creates a disk (possibly lazily) that will be attached later to a VM. When
    # VM locality is specified the disk will be placed near the VM so it won't have to move
    # when it's attached later.
    #
    # @param [Integer] size disk size in MB
    # @param [optional, String] vm_locality vm id if known of the VM that this disk will
    #                           be attached to
    # @return [String] opaque id later used by {#attach_disk}, {#detach_disk}, and {#delete_disk}
    def create_disk(size, vm_locality = nil)
      not_implemented(:create_disk)
    end

    ##
    # Deletes a disk
    # Will raise an exception if the disk is attached to a VM
    #
    # @param [String] disk disk id that was once returned by {#create_disk}
    # @return nil
    def delete_disk(disk_id)
      not_implemented(:delete_disk)
    end

    ##
    # Attaches a disk
    #
    # @param [String] vm vm id that was once returned by {#create_vm}
    # @param [String] disk disk id that was once returned by {#create_disk}
    # @return nil
    def attach_disk(vm_id, disk_id)
      not_implemented(:attach_disk)
    end

    ##
    # Detaches a disk
    #
    # @param [String] vm vm id that was once returned by {#create_vm}
    # @param [String] disk disk id that was once returned by {#create_disk}
    # @return nil
    def detach_disk(vm_id, disk_id)
      not_implemented(:detach_disk)
    end

    ##
    # Validates the deployment
    # @api not_yet_used
    def validate_deployment(old_manifest, new_manifest)
      not_implemented(:validate_deployment)
    end

    private

    def not_implemented(method)
      raise Bosh::Clouds::NotImplemented,
            "`#{method}' is not implemented by #{self.class}"
    end
  end

end
