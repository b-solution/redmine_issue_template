class IssueTemplate < ActiveRecord::Base
  include Redmine::SafeAttributes
  unloadable
  belongs_to :project
  belongs_to :author, :class_name => 'User', :foreign_key => 'author_id'
  belongs_to :tracker
  has_many :issue_checklist_templates
  
  before_save :check_default
  validates :project_id, :presence => true
  validates :title, :presence => true
  validates :tracker, :presence => true
  validates_uniqueness_of :title, :scope => :project_id
  acts_as_list :scope => :tracker
  
  accepts_nested_attributes_for :issue_checklist_templates
  
  # author and project should be stable.
  safe_attributes 'title', 'description', 'tracker_id', 'note', 'enabled', 'issue_title','is_default',
                  'enabled_sharing','visible_children', 'issue_checklist_template_attributes'
  def enabled?
    self.enabled == true
  end
  
  def <=>(issue_template)
    position <=> issue_template.position
  end

  #
  # In case set is_default and updated, others are also updated.
  #
  def check_default
    if is_default? && is_default_changed?
      IssueTemplate.update_all({:is_default => false},
                               ['project_id = ? AND tracker_id = ?', project_id, tracker_id])
    end
  end
  
  def checklist
    issue_checklist_templates || []
  end
end
