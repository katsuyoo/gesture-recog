function res = runexperimentbatch(batch, split, hyperParam, jobParam)
%% RUNEXPERIMENTBATCH runs experiment for each batch in paraleel and 
%  reports data.
%
%  ARGS
%  batch   - cell array of data.

nBatch = length(batch);

startTime=datestr(now, 'yyyy_mm_dd_HH_MM');

fprintf('\n-o-|-o-|-o-|-o-|-o-|-o-|-o-|-o-|-o-|-o-|-o-|-o-|-o-|-o-|-o-\n');
fprintf('\n-o-|-o-|-o-|    EXPERIMENT  %s   |-o-|-o-|-o-\n', startTime);
fprintf('\n-o-|-o-|-o-|-o-|-o-|-o-|-o-|-o-|-o-|-o-|-o-|-o-|-o-|-o-|-o-\n');
fprintf('Parameters:\n')
disp(hyperParam);

for iter = 1 : hyperParam.trainIter
  % Run experiments.
  verbose = jobParam.verbose;
  jm = findResource('scheduler', 'type', 'local');
  job = createJob(jm);

  ntask = zeros(nBatch, 2);

  for i = 1 : nBatch
    [nrow, ncol] = runexperimentparallel(split, i, hyperParam.model, ...
                   jobParam, job, iter);
    ntask(i, :) = [nrow ncol];
  end

  % Set jobData (global variable to all tasks)    
  if verbose, fprintf('Set job data...'); tid = tic(); end    
  set(job, 'PathDependencies', strread(jobParam.path, '%s', ...
      'delimiter', ';'));
  jobData.ntask = ntask;
  set(job, 'JobData', jobData);
  if verbose, t = toc(tid); fprintf('Done setting data (%.2f s)\n', t); end

  % Submit and wait
  submit(job);  
  if verbose, fprintf('Job submited\n'); end

  if jobParam.wait
    tid = tic();
    waitForState(job, 'finished');

    % Destroy job
    if jobParam.destroy,
      job.destroy();
    end

    if hyperParam.returnFeature
      res = arrayfun(@(x) x.OutputArguments{1}, job.Tasks, ...
                     'UniformOutput', false);
    else
      % Report results.
      fprintf('\n==========================================\n'); 

      res = batchresult(job, ntask);

      fprintf('Time(s) used\t');
      fprintf('%5.2f\n', toc(tid)); 
    end
  end
end
end