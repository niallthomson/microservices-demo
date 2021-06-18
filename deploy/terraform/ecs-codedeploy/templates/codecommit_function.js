var aws = require('aws-sdk');
var codecommit = new aws.CodeCommit({ apiVersion: '2015-04-13' });
var codepipeline = new aws.CodePipeline({ apiVersion: '2015-07-09' });

exports.handler = async (event, context) => {

  console.info("EVENT\n" + JSON.stringify(event, null, 2))

  let environmentName = process.env.ENVIRONMENT_NAME;
  
  var commits = event.Records[0].codecommit.references.map(function(reference) {
    return reference.commit;
  });
  console.log('Commits:', commits);

  var commit = commits[0];
  var component = event.Records[0].customData;
  
  //Get the repository from the event and show its git clone URL
  var repository = event.Records[0].eventSourceARN.split(":")[5];
  var params = {
    repositoryName: repository,
    afterCommitSpecifier: commit,
    afterPath: 'src/'+component+'/'
  };

  let differences = [];

  try {
    differences = await codecommit.getDifferences(params).promise();

    console.info("DIFFERENCES\n" + JSON.stringify(differences, null, 2))

    if ( differences.differences.length > 0 ) {
      console.log("DECISION: Run pipeline");

      let pipeline = await codepipeline.startPipelineExecution({
        name: environmentName+'-'+component
      }).promise();

      console.info("PIPELINE\n" + JSON.stringify(pipeline, null, 2))

      return true;
    } else {
      console.log("DECISION: No run");
    }
  }
  catch(err) {
    return err;
  }

  return true;
};