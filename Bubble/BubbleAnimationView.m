
#import "BubbleAnimationView.h"


@interface BubbleAnimationView ()

@property (nonatomic, strong) UIImage *dot;

@end


@implementation BubbleAnimationView

+(Class)layerClass
{
    return [CAEmitterLayer class];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self)
        [self reallyInit];
    
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self)
        [self reallyInit];
    
    return self;
}

-(void)reallyInit
{
    [self initLayer];
    self.userInteractionEnabled = YES;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    ((CAEmitterLayer *)self.layer).birthRate += 0.5;
}

-(void)createDot
{
    // Circle for the emitter cell. We make it slightly off-center, so that the
    // spin on the particle makes it wobble a bit.
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(80.0, 80.0), NO, 0.0);
    UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0.0, 0.0, 77.0, 77.0)];
    [[UIColor whiteColor] setFill];
    [path fill];
    self.dot = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
}

-(void)drawRect:(CGRect)rect
{

}

-(void)initLayer
{
    [self createDot];
    
    // Exported from ParticlePlayground, with minor edits.
    
    CAEmitterLayer *emitterLayer = (CAEmitterLayer *)self.layer;
    emitterLayer.name = @"emitterLayer";
    CGPoint emitterPosition = CGPointMake(CGRectGetWidth(self.frame) * .75, CGRectGetHeight(self.frame) * .5);
//    if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) emitterPosition.y = 10.0;
    emitterLayer.emitterPosition = emitterPosition;
    emitterLayer.emitterZPosition = 0;
    
    emitterLayer.emitterSize = CGSizeMake(CGRectGetWidth(self.frame) / 8.0, MAX(CGRectGetHeight(self.frame) / 30.0, 1.0));
    emitterLayer.emitterDepth = 0.00;
    
    emitterLayer.emitterShape = kCAEmitterLayerRectangle;
    
    emitterLayer.renderMode = kCAEmitterLayerAdditive;
    
    emitterLayer.seed = 4176518701;
    
    // Create the emitter Cell
    CAEmitterCell *emitterCell = [CAEmitterCell emitterCell];
    
    emitterCell.enabled = YES;
    
    emitterCell.contents = (id)self.dot.CGImage;
    emitterCell.contentsRect = CGRectMake(0.00, 0.00, 1.00, 1.00);
    
    emitterCell.magnificationFilter = kCAFilterLinear;
    emitterCell.minificationFilter = kCAFilterLinear;
    emitterCell.minificationFilterBias = 0.00;
    
    emitterCell.scale = CGRectGetWidth(self.frame) / 1000.0;
    emitterCell.scaleRange = emitterCell.scale * 0.75;
    emitterCell.scaleSpeed = -0.03;
    
    emitterCell.color = [[UIColor whiteColor] CGColor] ;
    emitterCell.redRange = .01;
    emitterCell.greenRange = 0.01;
    emitterCell.blueRange = .01;
    emitterCell.alphaRange = 0.47;
    
    emitterCell.redSpeed = .01;
    emitterCell.greenSpeed = .2;
    emitterCell.blueSpeed = .3;
    emitterCell.alphaSpeed = -0.30;
    
    emitterCell.lifetime = 8.00;
    emitterCell.lifetimeRange = 0.50;
    emitterCell.birthRate = 1.5;
    emitterCell.velocity = 4.00;
    emitterCell.velocityRange = 1.00;
    emitterCell.xAcceleration = 0.00;
    emitterCell.yAcceleration = -30.00;
    emitterCell.zAcceleration = 0.00;
    
    emitterCell.spin = 6.109;
    emitterCell.spinRange = 11.397;
    emitterCell.emissionLatitude = 2.915;
    emitterCell.emissionLongitude = 2.775;
    emitterCell.emissionRange = 3.489;
    
    emitterLayer.emitterCells = @[emitterCell];
}

@end