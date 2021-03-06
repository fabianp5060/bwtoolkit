require_relative 'bwuser'
class BWGroup < BWUser

    def group_exists?(group=nil)
        oci_cmd = :GroupGetListInSystemRequest
        config_hash = send(oci_cmd)
        abort "#{__method__} for #{oci_cmd} Default Options: #{config_hash}" if group == nil

        table_header = "groupTable"
        config_hash[:searchCriteriaGroupId][:value] = group
        response_hash,cmd_ok = get_table_response(oci_cmd,table_header,config_hash)

        group_exists = false
        ent_id = nil
        if response_hash.length == 1
            group_exists = true 
            ent_id = response_hash[0][:Organization_Id]
        end

        return cmd_ok,group_exists,ent_id,response_hash

    end

    def get_groups(ent=nil)
        oci_cmd = :GroupGetListInServiceProviderRequest
        config_hash = send(oci_cmd,ent)
        abort "#{__method__} for #{oci_cmd} Default Options: #{config_hash}" if ent == nil

        groups = Array.new
        table_header = "groupTable"
        response_hash,cmd_ok = get_table_response(oci_cmd,table_header,config_hash)
        if response_hash.is_a?(Array)
            response_hash.each { |group_hash| groups << group_hash[:Group_Id] }
        end

        return cmd_ok,groups
    end

    def get_groups_by_name(value=nil,mode=nil,case_insensitive=true)
        oci_cmd = :GroupGetListInSystemRequest
        config_hash = send(oci_cmd,value,mode,case_insensitive)
        # abort "#{__method__} for #{oci_cmd} Default Options: #{config_hash}" if 
        
        groups = Array.new
        table_header = "groupTable"
        response_hash,cmd_ok = get_table_response(oci_cmd,table_header,config_hash)
        if response_hash.is_a?(Array)
            response_hash.each { |group_hash| groups << group_hash[:Group_Id] }
        end

        return cmd_ok,groups

    end

    def get_group_admin_list(ele=nil)
        oci_cmd = :GroupAdminGetListRequest
        config_hash = send(oci_cmd,ele[:ent],ele[:group])
        abort "#{__method__} for #{oci_cmd} Default Options: #{config_hash}" if ele[:ent] == nil

        admins = Array.new
        table_header = "groupAdminTable"
        response_hash,cmd_ok = get_table_response(oci_cmd,table_header,config_hash)
        response_hash.each { |admin_hash| admins.push(admin_hash[:Administrator_ID])}

        return cmd_ok,admins
    end        

    def get_group_annoucement_list(ent=nil,group=nil)
        oci_cmd = :GroupAnnouncementFileGetListRequest
        config_hash = send(oci_cmd)
        config_hash[:serviceProviderId] = ent
        config_hash[:groupId] = group
        abort "#{__method__} for #{oci_cmd} Default Options: #{config_hash}" if ent == nil

        response_hash, cmd_ok = get_rows_response(oci_cmd,config_hash)
        return cmd_ok,response_hash
    end

    def get_group_aa_config(svc_id=nil)
        oci_cmd = :GroupAutoAttendantGetInstanceRequest20
        config_hash = send(oci_cmd,svc_id)
        abort "#{__method__} for #{oci_cmd} Default Options: #{config_hash}" if svc_id == nil

        response_hash,cmd_ok = get_nested_rows_response(oci_cmd,config_hash)

        return cmd_ok,response_hash
    end

    def get_group_aa_list(ent=nil,group=nil)
        oci_cmd = :GroupAutoAttendantGetInstanceListRequest
        config_hash = send(oci_cmd,ent,group)
        abort "#{__method__} for #{oci_cmd} Default Options: #{config_hash}" if ent == nil

        table_header = "autoAttendantTable"
        response_hash,cmd_ok = get_table_response(oci_cmd,table_header,config_hash)

        return cmd_ok,response_hash
    end

    def get_group_assigned_service_list(ent=nil,group=nil)
        oci_cmd = :GroupServiceGetAuthorizationListRequest
        config_hash = send(oci_cmd,ent,group)
        abort "#{__method__} for #{oci_cmd} Default Options: #{config_hash}" if ent == nil

        table_header = "groupServicesAuthorizationTable"
        response_hash,cmd_ok = get_table_response(oci_cmd,table_header,config_hash)                

        return cmd_ok,response_hash
    end

    def is_service_authorized?(ent=nil,group=nil,service)
        cmd_ok,response_hash = get_group_assigned_service_list(ent,group)

        service_assigned = false
        response_hash.each do |svc_info|
            service_assigned = true if svc_info[:Service_Name] == service && svc_info[:Authorized] == "true"
        end
        return service_assigned
    end

    def get_group_cc_list(ent=nil,group=nil)
        oci_cmd = :GroupCallCenterGetInstanceListRequest
        config_hash = send(oci_cmd,ent,group)
        abort "#{__method__} for #{oci_cmd} Default Options: #{config_hash}" if ent == nil

        table_header = "callCenterTable"

        response_hash,cmd_ok = get_table_response(oci_cmd,table_header,config_hash)

        return cmd_ok,response_hash
    end

    def get_group_cc_agents(svc_id)
        oci_cmd = :GroupCallCenterGetAgentListRequest
        config_hash = send(oci_cmd,svc_id)
        abort "#{__method__} for #{oci_cmd} Default Options: #{config_hash}" if svc_id == nil    

        table_header = "agentTable"
        response_hash,cmd_ok = get_table_response(oci_cmd,table_header,config_hash)   

        return cmd_ok,response_hash 
    end

    def add_group_custom_tag_for_device(ent=nil,group=nil,dev_type=nil,tag_name=nil,tag_value=nil)
        oci_cmd = :GroupDeviceTypeCustomTagAddRequest
        config_hash = send(oci_cmd,ent,group,dev_type,tag_name,tag_value)
        abort "#{__method__} for #{oci_cmd} Default Options: #{config_hash}" if ent == nil

        response,cmd_ok = send_request(oci_cmd,config_hash)
    end

    def get_group_custom_tags_for_device(ent=nil,group=nil,dev_name=nil)
        oci_cmd = :GroupDeviceTypeCustomTagGetListRequest
        config_hash = send(oci_cmd,ent,group,dev_name)
        abort "#{__method__} for #{oci_cmd} Default Options: #{config_hash}" if ent == nil

        table_header = 'groupDeviceTypeCustomTagsTable'
        response_hash,cmd_ok = get_table_response(oci_cmd,table_header,config_hash)

        return cmd_ok,response_hash
    end

    def delete_group_custom_tag_for_device(ent=nil,group=nil,dev_type=nil,tag_name=nil)
        oci_cmd = :GroupDeviceTypeCustomTagDeleteListRequest
        config_hash = send(oci_cmd,ent,group,dev_type,tag_name)
        abort "#{__method__} for #{oci_cmd} Default Options: #{config_hash}" if ent == nil

        response,cmd_ok = send_request(oci_cmd,config_hash)

        return cmd_ok,response
    end

    # Return Default Domain for Group
    def get_group_default_domain(ent=nil,group=nil)
        oci_cmd = :GroupDomainGetAssignedListRequest
        config_hash = send(oci_cmd)
        config_hash[:serviceProviderId] = ent
        config_hash[:groupId] = group
        abort "#{__method__} for #{oci_cmd} Default Options: #{config_hash}" if ent == nil

        response_hash,cmd_ok = get_rows_response(oci_cmd,config_hash) 
        default_domain = response_hash[:groupDefaultDomain]

        return cmd_ok,default_domain
    end

    #Get list of all devices in group
    def get_group_device_list(ent,group,dev_type=nil)
        oci_cmd = :GroupAccessDeviceGetListRequest
        config_hash = GroupAccessDeviceGetListRequest(ent,group,dev_type)
        table_header = 'accessDeviceTable'
        response_hash,cmd_ok = get_table_response(oci_cmd,table_header,config_hash)

        return cmd_ok,response_hash
    end

    #Get list of specific devices in group
    def get_group_device_list_by_type(ent,group,dev_type_list)
        oci_cmd = :GroupAccessDeviceGetListRequest
        table_header = 'accessDeviceTable'

        devices_list = Array.new
        dev_type_list.each do |dev|
            config_hash = send(oci_cmd,ent,group,dev)
            device_list,cmd_ok = get_table_response(oci_cmd,table_header,config_hash)
            devices_list += device_list 
        end

        return devices_list
    end

    def get_group_device_users(ent=nil,group=nil,device=nil)
        oci_cmd = :GroupAccessDeviceGetUserListRequest
        device_hash = {serviceProviderId: ent, groupId: group, deviceName: device}
        config_hash = send(oci_cmd)
        config_hash.merge!(device_hash)
        abort "#{__method__} for #{oci_cmd} Default Options: #{config_hash}" if ent == nil

        table_header = 'deviceUserTable'
        response_hash,cmd_ok = get_table_response(oci_cmd,table_header,config_hash)

        return cmd_ok,response_hash
    end

    def get_group_dn_list(ent,group)
    	oci_cmd = :GroupDnGetAssignmentListRequest
        table_header = "dnTable"
    	config_hash = GroupDnGetAssignmentListRequest()
    	config_hash[:serviceProviderId] = ent
    	config_hash[:groupId] = group

        #group_dn_list = @helpers.make_hoa
        expanded_tn_list = Array.new

        table_of_dns,cmd_ok = get_table_response(oci_cmd,table_header,config_hash)
        table_of_dns.each do |line|
            if line[:Phone_Numbers] =~ /\+1-(\d{10})\s-\s\+1-(\d{10})/
                start_tn = $1.to_i
                end_tn = $2.to_i
                while start_tn <= end_tn
                    tmp_hash = {
                        :Phone_Numbers => "+1-#{start_tn.to_s}", 
                        :Assigned_To => line[:Assigned_To],
                        :Department => line[:Department],
                        :Activated => line[:Activated],
                    }
                    expanded_tn_list.push(tmp_hash)
                    start_tn += 1
                end
            else
                expanded_tn_list.push(line)
            end
        end

        return cmd_ok,expanded_tn_list
    end

    def get_group_hg_config(svc_id=nil)
        oci_cmd = :GroupHuntGroupGetInstanceRequest20
        config_hash = send(oci_cmd,svc_id)
        abort "#{__method__} for #{oci_cmd} Default Options: #{config_hash}" if svc_id == nil

        response_hash,cmd_ok = get_nested_rows_response(oci_cmd,config_hash)

        table_header = "agentUserTable"
        assigned_users,cmd_ok = get_table_response(oci_cmd,table_header,config_hash)
        response_hash[:agentUserTable] = assigned_users

        return cmd_ok,response_hash
    end

    def get_group_hg_svc_config(svc_id=nil)
        cmd_ok,response_hash = get_group_hg_config(svc_id)
        svc_list = get_user_clean_svc_list(svc_id)
        if svc_list.length > 0
            svc_list.each do |svc| 
                puts "My SVC OCI COMMANDS"
                puts $bw_helper.get_svc_to_oci_map(svc)           
            end
        else
            puts "No SVC INFO"
        end

        return cmd_ok,response_hash
    end


    def get_group_hg_list(ent=nil,group=nil)
        oci_cmd = :GroupHuntGroupGetInstanceListRequest
        config_hash = send(oci_cmd,ent,group)
        abort "#{__method__} for #{oci_cmd} Default Options: #{config_hash}" if ent == nil

        # get_nested_rows does not handle nested tables right now
        table_header = "huntGroupTable"
        response_hash,cmd_ok = get_table_response(oci_cmd,table_header,config_hash)

        return cmd_ok,response_hash                

    end

    def get_group_profile(ent=nil,group=nil)
        oci_cmd = :GroupGetRequest14sp7
        config_hash = send(oci_cmd,ent,group)
        abort "#{__method__} for #{oci_cmd} Default Options: #{config_hash}" if ent == nil        

        response_hash,cmd_ok = get_nested_rows_response(oci_cmd,config_hash)
        return cmd_ok,response_hash
    end

    # Return Trunking Capacity from Group > Resources > Trunking Call Capacity
    def get_group_trunk_cap(ent=nil,group=nil)
        oci_cmd = :GroupTrunkGroupGetRequest14sp9
        config_hash = send(oci_cmd,ent,group)
        abort "#{__method__} for #{oci_cmd} Default Options: #{config_hash}" if ent == nil 

        response_hash,cmd_ok = get_nested_rows_response(oci_cmd,config_hash)
        trunk_cap = response_hash[:maxActiveCalls]

        return cmd_ok,trunk_cap
    end

    # Return Trunk Capacity assigned to Trunk Group from Group > Services > Trunk Groups > Profile > Max Active Calls Allowed
    def get_trunk_group_trunk_config(ent=nil,group=nil,tg_name=nil)
        oci_cmd = :GroupTrunkGroupGetInstanceRequest20sp1
        config_hash = send(oci_cmd,ent,group,tg_name)
        abort "#{__method__} for #{oci_cmd} Default Options: #{config_hash}" if ent == nil 

        response_hash,cmd_ok = get_nested_rows_response(oci_cmd,config_hash)

        return cmd_ok,response_hash
    end

    # Get List of All trunk groups in Group
    def get_trunk_group_trunk_list(ent=nil,group=nil)
        oci_cmd = :GroupTrunkGroupGetInstanceListRequest14sp4
        config_hash = send(oci_cmd,ent,group)
        abort "#{__method__} for #{oci_cmd} Default Options: #{config_hash}" if ent == nil  

        trunk_list = Array.new
        table_header = "trunkGroupTable"

        trunks,cmd_ok = get_table_response(oci_cmd,table_header,config_hash)    
        trunks.each { |trunk_hash| trunk_list << trunk_hash[:Name] }

        return cmd_ok,trunk_list
    end

    def get_users_assigned_to_service(ent=nil,group=nil,service=nil)
        oci_cmd = :GroupGetUserServiceAssignedUserListRequest
        config_hash = send(oci_cmd,ent,group,service)
        abort "#{__method__} for #{oci_cmd} Default Options: #{config_hash}" if ent == nil 

        user_list = Array.new
        table_header = "userListTable"

        list_of_users,cmd_ok = get_table_response(oci_cmd,table_header,config_hash)
        list_of_users.each { |user_hash| user_list << user_hash[:User_Id] }

        return cmd_ok,user_list
    end

    def mod_add_group_device(dev_hash,dev_mgmt_creds=nil)
        oci_cmd = :GroupAccessDeviceAddRequest14
        if dev_mgmt_creds == nil
            config_hash = GroupAccessDeviceAddRequest14(false)
            config_hash.merge!(dev_hash)
        else
            config_hash = GroupAccessDeviceAddRequest14(true)
            config_hash.merge!(dev_hash)
            config_hash[:accessDeviceCredentials].merge!(dev_mgmt_creds)
        end
        response,cmd_ok = send_request(oci_cmd,config_hash)

        return cmd_ok,response
    end    

    def mod_group_aa_profile(svc_mod_hash,ok_to_send=true)
        oci_cmd = :GroupAutoAttendantModifyInstanceRequest20
        config_template = send(oci_cmd)
        config_hash = $bw_helper.mod_config_hash(config_template,svc_mod_hash)

        config_hash[:businessHours] = {attr: {'xsi:nil' => "true"}}
        response,cmd_ok = send_request(oci_cmd,config_hash,ok_to_send)

        return cmd_ok,response
    end

    def mod_group_announcement_file(ent=nil,group=nil,file=nil,new_file=nil,type=nil)
        oci_cmd = :GroupAnnouncementFileModifyRequest
        config_hash = send(oci_cmd)
        config_hash[:serviceProviderId] = ent
        config_hash[:groupId] = group
        config_hash[:announcementFileKey][:name] = file
        config_hash[:mediaFileType] = type unless type == nil
        config_hash[:newAnnouncementFileName] = new_file

        abort "#{__method__} for #{oci_cmd} Default Options: #{config_hash}" if group == nil

        response,cmd_ok = send_request(oci_cmd,config_hash)

        return cmd_ok,response
    end

    def mod_group_intercept(ent=nil,group=nil,is_active)
        oci_cmd = :GroupInterceptGroupModifyRequest16
        config_template = send(oci_cmd)
        config_hash = $bw_helper.mod_config_hash(config_template,{serviceProviderId: ent,
            groupId: group,
            isActive: is_active}
            )
        response,cmd_ok = send_request(oci_cmd,config_hash)

        return cmd_ok,response
    end

    def mod_group_hg_profile(svc_mod_hash,ok_to_send=true)
        oci_cmd = :GroupHuntGroupModifyInstanceRequest
        config_template = send(oci_cmd)
        config_hash = $bw_helper.mod_config_hash(config_template,svc_mod_hash)

        response,cmd_ok = send_request(oci_cmd,config_hash)

        return cmd_ok,response
    end

    def mod_group_trunk_cap(ent=nil,group=nil,max_calls=nil)
        oci_cmd = :GroupTrunkGroupModifyRequest14sp9
        config_hash = send(oci_cmd,ent,group,max_calls)
        abort "#{__method__} for #{oci_cmd} Default Options: #{config_hash}" if ent == nil  

        response,cmd_ok = send_request(oci_cmd,config_hash)

        return cmd_ok,response        
    end

    def mod_group_tg_trunk_cap(ent=nil,group=nil,tg=nil,mod_config)
        oci_cmd = :GroupTrunkGroupModifyInstanceRequest20sp1
        config_hash = send(oci_cmd,ent,group,tg,mod_config)
        abort "#{__method__} for #{oci_cmd} Default Options: #{config_hash}" if ent == nil  

        response,cmd_ok = send_request(oci_cmd,config_hash)

        return cmd_ok,response   

    end

    def mod_group_unassign_dn(ent=nil,group=nil,tn_list=nil,ok_to_mod=true)
        oci_cmd = :GroupDnUnassignListRequest
        config_hash = send(oci_cmd,ent,group,tn_list)
        abort "#{__method__} for #{oci_cmd} Default Options: #{config_hash}" if ent == nil 

        response,cmd_ok = send_request(oci_cmd,config_hash,ok_to_mod)

        return cmd_ok,response
    end

end