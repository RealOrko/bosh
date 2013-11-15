require 'spec_helper'

module Bosh::Director
  describe JobInstanceRenderer do
    describe '#render' do
      let(:instance) { double('instance') }
      let(:job_template_loader) { instance_double('Bosh::Director::JobTemplateLoader') }
      subject(:job_instance_renderer) { JobInstanceRenderer.new(job, job_template_loader) }
      let(:job_template_renderer) { instance_double('Bosh::Director::JobTemplateRenderer') }

      let(:job) { double('job', templates: templates, name: 'foo') }



      context 'when job has no templates' do
        let(:templates) { [] }

        it 'returns emtpy array' do

          rendered_job_templates = job_instance_renderer.render(instance)
          expect(rendered_job_templates).to eq ([])
        end
      end

      context 'when job has one job_template' do
        let(:templates) { [double('template', name: 'a')] }
        let(:expected_rendered_templates) { [double('rendered template')] }

        before do
          job_template_renderer.stub(:render).with(job.name, instance).and_return(expected_rendered_templates[0])
        end

        it 'returns the rendered template for the given instance' do
          job_template_loader.stub(:process).with(templates[0]).and_return(job_template_renderer)

          rendered_job_templates = job_instance_renderer.render(instance)
          expect(rendered_job_templates).to eq (expected_rendered_templates)
        end

        context 'when called for multiple instances' do
          it 'only processes the source job templates once' do
            expect(job_template_loader).to receive(:process).with(templates[0]).and_return(job_template_renderer)

            job_instance_renderer.render(instance)
            job_instance_renderer.render(instance)
          end
        end
      end

      context 'when job has multiple job_templates sorted by name' do
        let(:templates) { [double('template1', name: 'b'), double('template2', name: 'a')] }
        let(:expected_rendered_templates) { [
          instance_double('Bosh::Director::RenderedJobTemplate', name: 'a'),
          instance_double('Bosh::Director::RenderedJobTemplate', name: 'b'),
        ] }
        let(:job_template_renderer2) { instance_double('Bosh::Director::JobTemplateRenderer') }


        before do
          job_template_loader.stub(:process).with(templates[0]).and_return(job_template_renderer)
          job_template_loader.stub(:process).with(templates[1]).and_return(job_template_renderer2)

          job_template_renderer.stub(:render).with(job.name, instance).and_return(expected_rendered_templates[1])
          job_template_renderer2.stub(:render).with(job.name, instance).and_return(expected_rendered_templates[0])
        end

        it 'returns the rendered templates for an instance' do
          rendered_job_templates = job_instance_renderer.render(instance)
          expect(rendered_job_templates).to eq (expected_rendered_templates)
        end
      end
    end
  end
end
