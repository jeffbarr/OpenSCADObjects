// Tiling of AWS service tiles
//
// Tiles from https://github.com/WayneStallwood/AWS-Tile-Generator/samples/*.stl must be in the same directory.
//
// TODO:
//
//	Generate more tiles
//	Options to print specific types of tiles (DB, Compute, by Color, etc)
//

// X Spacing
SpaceX = 32;

// Y Spacing
SpaceY = 41;

// Columns
CountX = 7;

// Rows
CountY = 5;

// Tile Scale
TileScale = 0.75;

// Tile Selection
TileSelection = "Ordered"; // [Ordered, Random]

// End of customizations
module _end_customizations_ () {};

Files = 
[
"Red_WAF.stl",
"Red2_Amplify.stl",
"Blue_Aurora.stl",
"Blue_DynamoDB.stl",
"Blue_Elasticache.stl",
"Blue_Neptune.stl",
"Blue_RDS.stl",
"Blue2_Cloud9.stl",
"Blue2_CodeBuild.stl",
"Blue2_CodeCommit.stl",
"Blue2_CodeDeploy.stl",
"Blue2_CodePipeline.stl",
"Blue2_X-Ray.stl",
"Green_Backup.stl",
"Green_EBS.stl",
"Green_EFS.stl",
"Green_FSX-Lustre.stl",
"Green_S3.stl",
"Orange_AutoScaling.stl",
"Orange_Batch.stl",
"Orange_Beanstalk.stl",
"Orange_EC2.stl",
"Orange_ECR.stl",
"Orange_ECS.stl",
"Orange_EKS.stl",
"Orange_EKS-A.stl",
"Orange_ELB.stl",
"Orange_Fargate.stl",
"Orange_ImageBuilder.stl",
"Orange_Lambda.stl",
"Orange_VMC.stl",
"Pink_API-GW.stl",
"Pink_App-Sync.stl",
"Pink_Event-Bridge.stl",
"Pink_SNS.stl",
"Pink_SQS.stl",
"Pink_Step.stl",
"Purple_CloudFront.stl",
"Purple_CloudWAN.stl",
"Purple_DX.stl",
"Purple_PrivateLink.stl",
"Purple_Route53.stl",
"Purple_TGW.stl",
"Purple_VPN.stl",
"Red_Cognito.stl",
"Red_Directory.stl",
"Red_Firewall.stl",
"Red_GuardDuty.stl",
"Red_IAM.stl",
"Red_Inspector.stl",
"Red_KMS.stl",
"Red_Macie.stl",
"Red_RAM.stl",
"Red_Security-Hub.stl",
"Red_Shield.stl"
];

FileCount = len(Files);

module RenderFile(File, Scale)
{
	scale([Scale, Scale, Scale])
	{
		translate([2, 47, 0])
		{
			rotate([0, 0, 270])
			{
				echo(Files[File]);
				import(Files[File]);
			}
		}
	}
}

for (y = [0 : 1 : CountY - 1])
{
	for (x = [0 : 1 : CountX - 1])
	{
		PtX = x * SpaceX;
		PtY = y * SpaceY;
		
		// Pick a tile
		FileIndex = 
			(TileSelection == "Ordered") ? ((y * CountY) + x) % FileCount :
		    (TileSelection == "Random")  ? rands(0, FileCount, 1)[0]      :
		                                   0;
		translate([PtX, PtY, 0])
		{
			echo(PtX, PtY, FileIndex);
			RenderFile(FileIndex, TileScale);
		}
	}
}

