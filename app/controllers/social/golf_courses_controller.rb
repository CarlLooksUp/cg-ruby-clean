class Social::GolfCoursesController < Social::SocialController
  helper_method :sort_column, :sort_direction

  GOLF_COURSE_FIELDS = [
                        {
                          'key' => 'name_object.name',
                          'label' => 'Course Name',
                          'sortable?' => true
                        },
                        {
                          'key' => 'city',
                          'label' => 'City',
                          'sortable?' => true
                        },
                        {
                          'key' => 'state',
                          'label' => 'State',
                          'sortable?' => true
                        }
                       ]

  def index
    @singular = "golf_course"
    @plural = "golf_courses"
    @nameables = GolfCourse.search_by_name(params[:search])
                          .order(sort_column + " " + sort_direction)
                          .paginate(:page => params[:page], :per_page => 30)
    @columns = GOLF_COURSE_FIELDS
    @not_first = request.query_string.present?
  end

  def show
    @singular = "golf_course"
    @plural = "golf_courses"
    @nameable = GolfCourse.find(params[:id])
    @rows = GOLF_COURSE_FIELDS
    render "social/nameable_detail"
  end

  def edit
  end

  private
    def sort_column
      permissible = GolfCourse.column_names.clone.concat(NameObject.column_names)
      permissible.include?(params[:sort]) ? params[:sort] : "name"
    end

    def sort_direction
      %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
    end
end
