# encoding : utf-8


class ResumesController < BeautifulController

  before_action :load_resume, :only => [:show, :edit, :update, :destroy]

  # Uncomment for check abilities with CanCan
  #authorize_resource

  def index
    session['fields'] ||= {}
    session['fields']['resume'] ||= (Resume.columns.map(&:name) - ["id"])[0..4]
    do_select_fields('resume')
    do_sort_and_paginate('resume')
    
    @q = Resume.ransack(
      params[:q]
    )

    @resume_scope = @q.result(
      :distinct => true
    ).sorting(
      params[:sorting]
    )
    
    @resume_scope_for_scope = @resume_scope.dup
    
    unless params[:scope].blank?
      @resume_scope = @resume_scope.send(params[:scope])
    end
    
    @resumes = @resume_scope.paginate(
      :page => params[:page],
      :per_page => 20
    ).to_a

    respond_to do |format|
      format.html{
        render
      }
      format.json{
        render :json => @resume_scope.to_a
      }
      format.csv{
        require 'csv'
        csvstr = CSV.generate do |csv|
          csv << Resume.attribute_names
          @resume_scope.to_a.each{ |o|
            csv << Resume.attribute_names.map{ |a| o[a] }
          }
        end 
        render :text => csvstr
      }
      format.xml{ 
        render :xml => @resume_scope.to_a
      }             
      format.pdf{
        pdfcontent = PdfReport.new.to_pdf(Resume,@resume_scope)
        send_data pdfcontent
      }
    end
  end

  def show
    respond_to do |format|
      format.html{
        render
      }
      format.json { render :json => @resume }
    end
  end

  def new
    @resume = Resume.new

    respond_to do |format|
      format.html{
        render
      }
      format.json { render :json => @resume }
    end
  end

  def edit
    
  end

  def create
    @resume = Resume.new(params_for_model)

    respond_to do |format|
      if @resume.save
        format.html {
          if params[:mass_inserting] then
            redirect_to resumes_path(:mass_inserting => true)
          else
            redirect_to resume_path(@resume), :flash => { :notice => t(:create_success, :model => "resume") }
          end
        }
        format.json { render :json => @resume, :status => :created, :location => @resume }
      else
        format.html {
          if params[:mass_inserting] then
            redirect_to resumes_path(:mass_inserting => true), :flash => { :error => t(:error, "Error") }
          else
            render :action => "new"
          end
        }
        format.json { render :json => @resume.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update

    respond_to do |format|
      if @resume.update_attributes(params_for_model)
        format.html { redirect_to resume_path(@resume), :flash => { :notice => t(:update_success, :model => "resume") }}
        format.json { head :ok }
      else
        format.html { render :action => "edit" }
        format.json { render :json => @resume.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @resume.destroy

    respond_to do |format|
      format.html { redirect_to resumes_url }
      format.json { head :ok }
    end
  end

  def batch
    attr_or_method, value = params[:actionprocess].split(".")

    @resumes = []    
    
    Resume.transaction do
      if params[:checkallelt] == "all" then
        # Selected with filter and search
        do_sort_and_paginate(:resume)

        @resumes = Resume.ransack(
          params[:q]
        ).result(
          :distinct => true
        )
      else
        # Selected elements
        @resumes = Resume.find(params[:ids].to_a)
      end

      @resumes.each{ |resume|
        if not Resume.columns_hash[attr_or_method].nil? and
               Resume.columns_hash[attr_or_method].type == :boolean then
         resume.update_attribute(attr_or_method, boolean(value))
         resume.save
        else
          case attr_or_method
          # Set here your own batch processing
          # resume.save
          when "destroy" then
            resume.destroy
          end
        end
      }
    end
    
    redirect_to :back
  end

  def treeview

  end

  def treeview_update
    modelclass = Resume
    foreignkey = :resume_id

    render :nothing => true, :status => (update_treeview(modelclass, foreignkey) ? 200 : 500)
  end
  
  private 
  
  def load_resume
    @resume = Resume.find(params[:id])
  end

  def params_for_model
    params.require(:resume).permit(Resume.permitted_attributes)
  end
end

