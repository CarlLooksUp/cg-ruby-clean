class Social::RadioStationsController < Social::SocialController
  helper_method :sort_column, :sort_direction

  RADIO_STATION_FIELDS = [
                          {
                            'key' => 'name_object.name',
                            'label' => 'Station Name',
                            'sortable?' => true
                          },
                          {
                            'key' => 'frequency',
                            'label' => 'Frequency',
                            'sortable?' => true
                          },
                          {
                            'key' => 'call_sign',
                            'label' => 'Call Sign',
                            'sortable?' => true
                          },
                          {
                            'key' => 'format',
                            'label' => 'Format',
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
                          },
                         ]

  def index
    @singular = "radio_station"
    @plural = "radio_stations"
    @nameables = RadioStation.search_by_name(params[:search])
                             .order(sort_column + " " + sort_direction)
                             .paginate(:page => params[:page], :per_page => 30)
    @columns = RADIO_STATION_FIELDS
    @not_first = request.query_string.present?
  end

  def show
    @singular = "radio_station"
    @plural = "radio_stations"
    @nameable = RadioStation.find(params[:id])
    @rows = RADIO_STATION_FIELDS
    render "social/nameable_detail"
  end

  def edit
    
  end

  private
    def sort_column
      permissible = RadioStation.column_names.clone.concat(NameObject.column_names)
      permissible.include?(params[:sort]) ? params[:sort] : "name"
    end

    def sort_direction
      %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
    end
end
