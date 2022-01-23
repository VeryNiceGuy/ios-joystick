
#import "GameViewController.h"
#import <OpenGLES/ES2/glext.h>
#import "JoystickPoint.h"
#import "Joystick.h"
#import "Common.h"

@interface GameViewController () {
    GLuint _shaderProgramForJoystickPoint;
    GLuint _shaderProgramForJoystick;
    
    Joystick* joystick;
    JoystickPoint* joystickPoint;
}
@property (strong, nonatomic) EAGLContext *context;
@property (strong, nonatomic) NSTimer *timer;

- (void)setupGL;
- (BOOL)loadShaders;
- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file;
- (BOOL)linkProgram:(GLuint)prog;
- (BOOL)validateProgram:(GLuint)prog;
@end

@implementation GameViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];

    if (!self.context) {
        NSLog(@"Failed to create ES context");
    }
    
    GLKView *view = (GLKView *)self.view;
    view.context = self.context;
    view.drawableDepthFormat = GLKViewDrawableDepthFormatNone;
    
    [self setupGL];
    
    UILongPressGestureRecognizer *tapRecognizer = [[UILongPressGestureRecognizer alloc]
                                                   initWithTarget:self action:@selector(respondToLongTapGesture:)];
    tapRecognizer.minimumPressDuration = 0;
    [self.view addGestureRecognizer:tapRecognizer];

}

- (IBAction)respondToLongTapGesture:(UILongPressGestureRecognizer *)recognizer {
    CGPoint location = [recognizer locationInView:self.view];
    
    if(recognizer.state == UIGestureRecognizerStateBegan)
    {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0f
                                                      target:self
                                                    selector:@selector(longTapGestureInterval:)
                                                    userInfo:nil
                                                     repeats:YES];
        
        joystick->isButtonTapped(location.x, location.y);
    }
    
    if(recognizer.state == UIGestureRecognizerStateEnded)
    {
        [self.timer invalidate];
        joystick->tappingEnded();
    }
}

- (void)longTapGestureInterval:(NSTimer*)timer {
    joystick->tapInterval();
}

- (void)dealloc
{    
    delete joystick;
    delete joystickPoint;
    
    if ([EAGLContext currentContext] == self.context) {
        [EAGLContext setCurrentContext:nil];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];

    if ([self isViewLoaded] && ([[self view] window] == nil)) {
        self.view = nil;
        
        if ([EAGLContext currentContext] == self.context) {
            [EAGLContext setCurrentContext:nil];
        }
        self.context = nil;
    }
}

- (void)setupGL
{
    [EAGLContext setCurrentContext:self.context];
    
    [self loadShaders];
    
    glEnable(GL_CULL_FACE);
    glEnable(GL_BLEND);
    
    glBlendFunc (GL_ONE, GL_ONE);
    glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
    
    NSError *theError;
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"atlas" ofType:@"png"];
    GLKTextureInfo *textureInfo = [GLKTextureLoader textureWithContentsOfFile:filePath options:nil error:&theError];
    
    glBindTexture(textureInfo.target, textureInfo.name);
    glEnable(textureInfo.target);
    
    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    
    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    
    joystickPoint = new JoystickPoint(self.view.bounds.size.width,
                          self.view.bounds.size.height,
                          _shaderProgramForJoystickPoint);
    
    joystick = new Joystick(0,
                             -180.0f,
                             self.view.bounds.size.width,
                             self.view.bounds.size.height,
                             textureInfo.name,
                            textureInfo.width,
                            textureInfo.height,
                             _shaderProgramForJoystick,
                            *joystickPoint);
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    glClear(GL_COLOR_BUFFER_BIT);
    
    joystick->draw();
    joystickPoint->draw();
}

- (BOOL)loadShaders
{
    GLuint vertShader, fragShader;
    NSString *vertShaderPathname, *fragShaderPathname;
    
    _shaderProgramForJoystickPoint = glCreateProgram();
    _shaderProgramForJoystick = glCreateProgram();
    
    vertShaderPathname = [[NSBundle mainBundle] pathForResource:@"ShaderForJoystick" ofType:@"vsh"];
    if (![self compileShader:&vertShader type:GL_VERTEX_SHADER file:vertShaderPathname]) {
        NSLog(@"Failed to compile vertex shader");
        return NO;
    }
    
    fragShaderPathname = [[NSBundle mainBundle] pathForResource:@"ShaderForJoystick" ofType:@"fsh"];
    if (![self compileShader:&fragShader type:GL_FRAGMENT_SHADER file:fragShaderPathname]) {
        NSLog(@"Failed to compile fragment shader");
        return NO;
    }
    
    glAttachShader(_shaderProgramForJoystick, vertShader);
    glAttachShader(_shaderProgramForJoystick, fragShader);
    
    glBindAttribLocation(_shaderProgramForJoystick, VertexAttribPosition, "positionAttrib");
    glBindAttribLocation(_shaderProgramForJoystick, VertexAttribUV, "uv0");
    
    if (![self linkProgram:_shaderProgramForJoystick]) {
        NSLog(@"Failed to link program: %d", _shaderProgramForJoystick);
        
        if (vertShader) {
            glDeleteShader(vertShader);
            vertShader = 0;
        }
        if (fragShader) {
            glDeleteShader(fragShader);
            fragShader = 0;
        }
        if (_shaderProgramForJoystick) {
            glDeleteProgram(_shaderProgramForJoystick);
            _shaderProgramForJoystick = 0;
        }
        
        return NO;
    }
    
    if (vertShader) {
        glDetachShader(_shaderProgramForJoystick, vertShader);
        glDeleteShader(vertShader);
    }
    
    if (fragShader) {
        glDetachShader(_shaderProgramForJoystick, fragShader);
        glDeleteShader(fragShader);
    }
    
    vertShaderPathname = [[NSBundle mainBundle] pathForResource:@"ShaderForJoystickPoint" ofType:@"vsh"];
    if (![self compileShader:&vertShader type:GL_VERTEX_SHADER file:vertShaderPathname]) {
        NSLog(@"Failed to compile vertex shader");
        return NO;
    }
    
    fragShaderPathname = [[NSBundle mainBundle] pathForResource:@"ShaderForJoystickPoint" ofType:@"fsh"];
    if (![self compileShader:&fragShader type:GL_FRAGMENT_SHADER file:fragShaderPathname]) {
        NSLog(@"Failed to compile fragment shader");
        return NO;
    }
    
    glAttachShader(_shaderProgramForJoystickPoint, vertShader);
    glAttachShader(_shaderProgramForJoystickPoint, fragShader);
    
    glBindAttribLocation(_shaderProgramForJoystickPoint, VertexAttribPosition, "positionAttrib");
    
    if (![self linkProgram:_shaderProgramForJoystickPoint]) {
        NSLog(@"Failed to link program: %d", _shaderProgramForJoystickPoint);
        
        if (vertShader) {
            glDeleteShader(vertShader);
            vertShader = 0;
        }
        if (fragShader) {
            glDeleteShader(fragShader);
            fragShader = 0;
        }
        if (_shaderProgramForJoystick) {
            glDeleteProgram(_shaderProgramForJoystickPoint);
            _shaderProgramForJoystick = 0;
        }
        
        return NO;
    }
    
    if (vertShader) {
        glDetachShader(_shaderProgramForJoystickPoint, vertShader);
        glDeleteShader(vertShader);
    }
    
    if (fragShader) {
        glDetachShader(_shaderProgramForJoystickPoint, fragShader);
        glDeleteShader(fragShader);
    }
    
    return YES;
}

- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file
{
    GLint status;
    const GLchar *source;
    
    source = (GLchar *)[[NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:nil] UTF8String];
    if (!source) {
        NSLog(@"Failed to load vertex shader");
        return NO;
    }
    
    *shader = glCreateShader(type);
    glShaderSource(*shader, 1, &source, NULL);
    glCompileShader(*shader);
    
    glGetShaderiv(*shader, GL_COMPILE_STATUS, &status);
    if (status == 0) {
        glDeleteShader(*shader);
        return NO;
    }
    
    return YES;
}

- (BOOL)linkProgram:(GLuint)prog
{
    GLint status;
    glLinkProgram(prog);
    
    glGetProgramiv(prog, GL_LINK_STATUS, &status);
    if (status == 0) {
        return NO;
    }
    
    return YES;
}

- (BOOL)validateProgram:(GLuint)prog
{
    GLint logLength, status;
    
    glValidateProgram(prog);
    glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(prog, logLength, &logLength, log);
        NSLog(@"Program validate log:\n%s", log);
        free(log);
    }
    
    glGetProgramiv(prog, GL_VALIDATE_STATUS, &status);
    if (status == 0) {
        return NO;
    }
    
    return YES;
}

@end
