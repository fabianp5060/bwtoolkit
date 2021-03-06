class GetRegByDeviceType

	def initialize(all_poly,counts_only,ent=nil,group=nil)
		@ent_groups = nil
		if ent == nil
			@ent_groups = $bw.get_groups_in_system
		elsif ent && group == nil
			cmd_ok, groups = $bw.get_groups(ent)
			@ent_groups = {ent => groups}
		else
			@ent_groups = {ent => [group]}
		end
		@device_search_list = ['Polycom Soundpoint IP 500', 'Polycom Soundpoint IP 601'] 
		@device_search_list = $bw.get_sys_poly_device_types if all_poly == true
		@device_search_list = ['Grandstream HT-818', 'Grandstream GXW4008']
		puts "Searching System for Registrations on the following devices:\n #{@device_search_list}\n---------------------------------------\n"
		@counts = false
		@counts = counts_only if counts_only == "true"

	end

	def get_poly_list
		curr_date = Time.now.strftime("%-m/%-d/%y")
		puts @counts == true ? "Enterprise,Group,Configured,Registered" : "\"Date\"|\"Enterprise\"|\"Group - Group Name\"|\"ConfiguredDeviceType\"|\"ActualDeviceType\"|\"DeviceVersion\"|\"DeviceConfigType\"|\"DeviceMac\""
		@ent_groups.each do |ent,groups|
			groups.each do |group|
				cmd_ok,g_profile = $bw.get_group_profile(ent,group)

				# Get Group Name (Remove surrounding quotes as I add that back in when I do the final print)
				# If Group Name doesn't exist add __NONE__
			 	group_name = g_profile.has_key?(:groupName) ? g_profile[:groupName].gsub(/\"(.*)\"/, '\1') : "__NONE__"

			 	# Get List of Devices for group
				devices_list = $bw.get_group_device_list_by_type(ent,group,@device_search_list)

				#For each device get UA (if registered), and other device info
				ua_device_list = get_reg_info(ent,group,devices_list)

				#Get count of devices both deg and configured
				configed_devices = devices_list.length
				reged_devices = ua_device_list.length

				#Print results, if $options[:counts] (IE -s true) print only summary information, otherwise print details
				@counts == true ? print_poly_reg_counts(ent,group,group_name,configed_devices,reged_devices) : print_poly_reg_list(curr_date,ent,group,group_name,ua_device_list)
			end
		end


	end

	def print_poly_reg_counts(ent,group,group_name,configed_devices,reged_devices)
		puts "#{ent}|#{group} - #{group_name}|#{configed_devices}|#{reged_devices}" if configed_devices > 0
	end

	def print_poly_reg_list(date,ent,group,group_name,ua_device_list)
		ua_device_list.each { |dev_mac,dev_info| puts "\"#{date}\"|\"#{ent}\"|\"#{group} - #{group_name}\"|\"#{dev_info.join("\"|\"")}\"|\"#{dev_mac}\"" }		
	end

	def get_reg_info(ent,group,devices_list)
	    ua_device_list = Hash.new(Array.new)

	    devices_list.each do |device_list|
	    	next if device_list[:MAC_Address] == "__NIL__"
	    	dev_name = device_list[:Device_Name]
	    	
	    	# First way to get UA info 
	    	config_type,config_dev_type,version = get_phone_config_info(ent,group,dev_name)	
			cmd_ok, user_ids = $bw.get_users_assigned_to_device(ent,group,dev_name)
			user_ids.each do |user|
				#Skip User Reg Lookup if we have already found the Device Info
				next if ua_device_list.has_key?(device_list[:MAC_Address])

				cmd_ok,user_reg = $bw.get_user_register_status(user)
				user_reg.each do |line_reg|
					dev_type,dev_ver,dev_mac = parse_ua(line_reg[:User_Agent])

					#Insert configured MAC if MAC doesn't exist within User-Agent string
					dev_mac = device_list[:MAC_Address] unless dev_mac
					ua_device_list[dev_mac] = [config_dev_type,dev_type,dev_ver,config_type]
				end	    
			end	
			# End First Way
							
	    	## 2nd Way - UA info is cached and old, not a very accurate way to get "current" registrations
	    	#config_dev_type is the Configured Identity/Device Profile (dev_type is the actual device model from User-Agent)
	    	# config_type,config_dev_type,version = get_phone_config_info(ent,group,dev_name)
	    	# if version
	    	# 	dev_type,dev_ver,dev_mac = parse_ua(version)
	    	# 	dev_mac = device_list[:MAC_Address] unless dev_mac
	    	# 	ua_device_list[dev_mac] = [config_dev_type,dev_type,dev_ver,config_type]
	    	# end


	    end

	    return ua_device_list
	end

	def get_phone_config_info(ent,group,dev_name)
		# dev_info[:version] now shows registered User-Agent
		cmd_ok,dev_info = $bw.get_user_device_info(ent,group,dev_name)
		return dev_info[:configurationMode],dev_info[:deviceType],dev_info[:version]
	end

	def parse_ua(ua)
		dev_type = "#{ua}"
		dev_ver = "unknown"
		dev_mac = "unknown"

		if @device_search_list.include?('Grandstream HT-818')
			/Grandstream\sHT818\s(.*)$/.match(ua)
				dev_ver = $1
		else			
			/(Polycom[VS].+)-UA\/([\.\d]+)/.match(ua)
				dev_type = $1
				dev_ver = $2
			/_(\w{12})$/.match(ua)		
				dev_mac = $3
		end
		return dev_type,dev_ver,dev_mac
	end	

end
