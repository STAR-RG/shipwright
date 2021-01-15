FROM jupyter/base-notebook                                                                                                                
                                                                                                                                          
MAINTAINER Pawel T.  Jochym <pawel.jochym@ifj.edu.pl>                                                                                     
                                                                                                                                          
USER root                                                                                                                                 
                                                                                                                                          
# Add dependencies                                                                                                                        
RUN sed 's/main/main contrib non-free/g' /etc/apt/sources.list                                                                            
RUN echo "deb http://cdn-fastly.deb.debian.org/debian jessie-backports main contrib non-free" > /etc/apt/sources.list.d/backports.list    
                                                                                                                                          
RUN apt-get update                                                                                                                        
RUN apt-get -qy upgrade                                                                                                                   
RUN apt-get -qy install git apt-utils                                                                                                     
RUN apt-get -qy install quantum-espresso quantum-espresso-data  && apt-get clean                                                                        
                                                                                                                                          
# Non-essential dependencies                                                                                                              
#RUN apt-get install -qy htop abinit-doc pandoc                                                                                            
#RUN apt-get install -qy texlive-latex-recommended texlive-fonts-recommended texlive-latex-extra && apt-get clean                          
                                                                                                                                          
# Extra dependencies                                                                                                                      
#RUN apt-get update                                                                                                                        
#RUN apt-get install -y ffmpeg && apt-get clean                                                                                            
                                                                                                                                          
RUN apt-get clean                                                                                                                         
                                                                                                                                          
# Conda deps                                                                                                                              
USER jovyan                                                                                                                               
RUN conda config --add channels conda-forge                                                                                               
RUN conda config --add channels jochym                                                                                                    
RUN conda install -y scipy numpy matplotlib ase spglib nglview elastic phonopy                                                            
RUN conda install -y jupyter_contrib_nbextensions                                                                                         
RUN conda install -y -c damianavila82 rise                                                                                                
RUN conda update -y --all                                                                                                                 
RUN conda clean -tipsy                                                                                                                    
                                                                                                                                          
# Materials                                                                                                                               
USER root                                                                                                                                 
COPY . /home/jovyan/work                                                                                                                  
RUN chown -R jovyan:users /home/jovyan/work                                                                                               
                                                                                                                                          
USER jovyan                                                                                                                               
