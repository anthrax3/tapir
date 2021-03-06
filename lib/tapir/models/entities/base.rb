module Entities
  class Base
    include Mongoid::Document
    include Mongoid::Timestamps

    include TenantAndProjectScoped

    extend ActiveModel::Naming

    field :age, type: Date
    field :confidence, type: Integer
    field :name, type: String
    field :status, type: String
    field :comment, type: String # Catch-all unstructured data field

    validates_uniqueness_of :name, :scope => [:tenant_id,:project_id,:_type]
    
    has_many :entity_mappings, as: :connection, :autosave => true
    has_many :task_runs, as: :completed_tasks

    def to_s
      "#{entity_type.capitalize}: #{name}"
    end

    def self.descendants
      ObjectSpace.each_object(Class).select { |klass| klass < self }
    end

    # Class method to convert to a path
    def self.underscore
      self.class.to_s.downcase.gsub("::","_")
    end

    def all
      entities = []
      Entities::Base.unscoped.descendants.each do |x|
        x.all.each {|y| entities << y } unless x.all == [] 
      end
    entities
    end
    
    def entity_type
      self.class.to_s.downcase.split("::").last
    end

    #
    # This method lets you query the available tasks for this entity type
    #
    def tasks
      TapirLogger.instance.log "Getting tasks for #{self}"
      tasks = TaskManager.instance.get_tasks_for(self)
    tasks.sort_by{ |t| t.name.downcase }
    end

    #
    # This method lets you run a task on this entity
    #
    def run_task(task_name, task_run_set_id, options={})
      TapirLogger.instance.log "Asking task manager to queue task #{task_name} run on #{self} with options: #{options} - part of taskrun set: #{task_run_set_id}"
      TaskManager.instance.queue_task_run(task_name, task_run_set_id, self, options)
    end

    #
    # This method lets you find all available children
    #
    def children
      
      TapirLogger.instance.log "Finding children for #{self}"
      children = []
      EntityMapping.all.each do |mapping| 

        # Go through each associated entity mapping, and find mappings where the parent_id is us
        # which means that the child_id is some other entity, and it's a child
        
        # the to_s is important, otherwise self.id returns a :Moped::BSON::ObjectID
        children << mapping.get_child if mapping.parent_id == self.id.to_s

        # TODO - what happens if parent_id and child_id are the same. We'll
        # end up grabbing it. Could that break any assumptions?
      end
      
    children
    end

    #
    # This method lets you find all available parents
    #
    def parents

      TapirLogger.instance.log "Finding parents for #{self}"
      parents = []
      self.entity_mappings.each do |mapping|

        # Go through each associated entity mapping, and find mappings where the child_id is us 
        # which means that the parent_id is some other entity, and it's a parent
    
        # the to_s is important, otherwise self.id returns a :Moped::BSON::ObjectId
        parents << mapping.get_parent if mapping.child_id == self.id.to_s  

        # TODO - what happens if parent_id and child_id are the same. We'll
        # end up grabbing it. Could that break any assumptions?

      end
    parents
    end

    #
    # This method lets you find all immediate parent's task runs .. that found this entity  
    #
    def incoming_task_runs
      TapirLogger.instance.log "Finding task runs for #{self}"
      incoming_task_runs = []

      self.entity_mappings.each do |mapping|
        incoming_task_runs << mapping.get_task_run if mapping.get_child == self
      end
    incoming_task_runs
    end

    ###
    ### Pulled out of entity_helper.rb
    ###

    def to_s
      "#{self.class} #{self.name}"
    end
    
    def entity_type
      self.class.to_s.downcase.split("::").last
    end

    #
    # This method lets you query the available tasks for this entity type
    #
    def tasks
      TapirLogger.instance.log "Getting tasks for #{self}"
      tasks = TaskManager.instance.get_tasks_for(self)
    tasks.sort_by{ |t| t.name.downcase }
    end

    #
    # This method lets you run a task on this entity
    #
    def run_task(task_name, task_run_set_id, options={})
      TapirLogger.instance.log "Asking task manager to queue task #{task_name} run on #{self} with options: #{options} - part of taskrun set: #{task_run_set_id}"
      TaskManager.instance.queue_task_run(task_name, task_run_set_id, self, options)
    end

  end
end