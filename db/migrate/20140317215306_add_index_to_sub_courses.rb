class AddIndexToSubCourses < ActiveRecord::Migration
  def change
    add_index :sub_courses, :golf_course_id
  end
end
