module Overclock
  module Aws
    module RDS
      SERIALIZE_ATTRS = [
        :allocated_storage            ,
        :auto_minor_version_upgrade   ,
        :availability_zone            ,
        :backup_retention_period      ,
        :character_set_name           ,
        :db_instance_class            ,
        :db_instance_identifier       ,
        :db_name                      ,
        :db_parameter_group_name      ,
        :db_security_groups           ,
        :db_subnet_group_name         ,
        :engine                       ,
        :engine_version               ,
        :iops                         ,
        :license_model                ,
        :master_user_password         ,
        :master_username              ,
        :multi_az                     ,
        :option_group_name            ,
        :port                         ,
        :preferred_backup_window      ,
        :preferred_maintenance_window ,
        :publicly_accessible          ,
        :vpc_security_group_ids
      ]

      DESERIALIZE_ATTRS = [
        :allocated_storage            ,
        :auto_minor_version_upgrade   ,
        :backup_retention_period      ,
        :character_set_name           ,
        :db_instance_class            ,
        :db_instance_identifier       ,
        :db_name                      ,
        :engine                       ,
        :engine_version               ,
        :iops                         ,
        :license_model                ,
        :master_username              ,
        :multi_az                     ,
        :preferred_backup_window      ,
        :preferred_maintenance_window ,
        :endpoint_address
      ]

      def instance(id = new_resource.id)
        @instance ||= rds.db_instances[id]
      end

      def rds(key = new_resource.aws_access_key, secret = new_resource.aws_secret_access_key)
        begin 
          require 'aws-sdk'
        rescue LoadError
          Chef::Log.error("Missing gem 'aws-sdk'. Use the default aws-rds recipe to install it first.")
        end
        @rds ||= AWS::RDS.new(access_key_id: key, secret_access_key: secret)
      end

      def create_instance(id = new_resource.id)
        if @instance = rds.db_instances.create(id, serialize_attrs)
          while (instance.status != 'available') do
            sleep 2
          end
        end
      end

      def set_node_attrs
        node.override[:aws_rds][new_resource.id] = deserialize_attrs
      end
private

      def serialize_attrs
        result = {}
        SERIALIZE_ATTRS.each do | key |
          if value = new_resource.send(key)
            result[key] = value
          end
        end
        result
      end

      def deserialize_attrs
        result = {}
        DESERIALIZE_ATTRS.each do |attr|
          result[attr] = instance.send(attr)
        end
        result
      end
    end
  end
end