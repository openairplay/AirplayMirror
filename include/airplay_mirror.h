


typedef struct mirror_context{
    char name[256];
    int width;
    int height;
    void* ref;
    
    void (*video_data_receive)(unsigned char* buffer, long buflen, int payload,void* ref);
    
    void (*audio_data_receive)(unsigned char* buffer, long buflen,void* ref);

	void(*airplay_did_stop)(void* ref);

}mirror_context;

int start_mirror(mirror_context* context);
void stop_mirror(void);
