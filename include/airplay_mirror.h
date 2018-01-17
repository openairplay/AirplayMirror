


typedef struct mirror_context{
    char name[256];
    int width;
    int height;
    void (*data_receive)(unsigned char* buffer, int buflen, int payload,void* ref);
    void* ref;
}mirror_context;

void start_mirror(mirror_context* context);
void stop_mirror();
