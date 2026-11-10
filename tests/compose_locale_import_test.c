#define _GNU_SOURCE
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>
#include <unistd.h>
char **process_envp;
extern char **environ;
extern char compose_locale_installed_tag[32];
uint32_t compose_locale_import_xcompose(const char *);
uint32_t compose_locale_load(const char *);
uint32_t compose_locale_lookup(uint32_t,uint32_t,const uint32_t *,uint32_t *);
uint32_t compose_locale_prefix(uint32_t,uint32_t,const uint32_t *);
uint32_t compose_locale_remove_pack(const char *);
static void need(int ok,const char *what){if(!ok){fprintf(stderr,"native XCompose test: %s\n",what);exit(1);}}
static void write_text(const char *p,const char *s){FILE *f=fopen(p,"wb");need(f!=NULL,"create fixture");need(fwrite(s,1,strlen(s),f)==strlen(s),"write fixture");need(fclose(f)==0,"close fixture");}
int main(void){
    char tmp[]="/tmp/nekoedit-xcompose-ui-XXXXXX",*home=mkdtemp(tmp);
    char src[512],app[512],loc[768],pack[1024],sym[512],inc[512];
    struct stat st;uint32_t in[4],out[8],n;
    const char *rules=
      "# In-app native import test\n"
      "<Multi_key> <o> <c> : \"©\"\n"
      "<Multi_key> <o> <c> : \"Neko\"\n"
      "<Multi_key> <n> <e> <k> : \"Neko\"\n"
      "<Multi_key> <t> <e> <s> <t> : \"TEST\"\n"
      "<Multi_key> <space> <quotedbl> : \"ASCII\"\n"
      "<Multi_key> <e> <x> : \"\\xC3\\xA9\"\n"
      "<Multi_key> <u> <x> : \"\\u03A9\"\n"
      "<Multi_key> <a> <m> : \"A\\u0301\"\n"
      "<Multi_key> <a> <e> : \"short\"\n"
      "<Multi_key> <a> <e> <x> : \"long\"\n"
      "<dead_acute> <a> : \"á\"\n"
      "<dead_grave> <e> : \"è\"\n";
    need(home!=NULL,"mkdtemp");
    need(setenv("HOME",home,1)==0,"set HOME");
    process_envp=environ;
    snprintf(src,sizeof(src),"%s/nekoedit-test.XCompose",home);write_text(src,rules);
    need(compose_locale_import_xcompose(src)==1,"valid file rejected");
    need(strcmp(compose_locale_installed_tag,"nekoedit-test.UTF-8")==0,"tag from filename");
    snprintf(app,sizeof(app),"%s/.nekoedit",home);
    snprintf(loc,sizeof(loc),"%s/locales",app);
    snprintf(pack,sizeof(pack),"%s/nekoedit-test.UTF-8.nlp",loc);
    need(stat(app,&st)==0&&(st.st_mode&0777)==0700,"app directory mode");
    need(stat(loc,&st)==0&&(st.st_mode&0777)==0700,"locale directory mode");
    need(stat(pack,&st)==0&&S_ISREG(st.st_mode)&&(st.st_mode&0777)==0600,"pack file/mode");
    need(compose_locale_load("nekoedit-test.UTF-8")==1,"runtime rejected generated pack");
    in[0]='o';in[1]='c';n=compose_locale_lookup(0,2,in,out);
    need(n==4&&out[0]=='N'&&out[3]=='o',"later duplicate override");
    in[0]='n';in[1]='e';in[2]='k';n=compose_locale_lookup(0,3,in,out);
    need(n==4&&out[0]=='N'&&out[3]=='o',"three-symbol sequence");
    in[0]='t';in[1]='e';in[2]='s';in[3]='t';n=compose_locale_lookup(0,4,in,out);
    need(n==4&&out[0]=='T'&&out[3]=='T',"four-symbol sequence");
    in[0]=0x20;in[1]=0x22;n=compose_locale_lookup(0,2,in,out);
    need(n==5&&out[0]=='A'&&out[4]=='I',"named ASCII keysyms");
    in[0]='e';in[1]='x';n=compose_locale_lookup(0,2,in,out);
    need(n==1&&out[0]==0xe9,"hex byte escape");
    in[0]='u';in[1]='x';n=compose_locale_lookup(0,2,in,out);
    need(n==1&&out[0]==0x3a9,"Unicode scalar escape");
    in[0]='a';in[1]='m';n=compose_locale_lookup(0,2,in,out);
    need(n==2&&out[0]=='A'&&out[1]==0x301,"multi-scalar output");
    in[0]=0x301;in[1]='a';n=compose_locale_lookup(1,2,in,out);
    need(n==1&&out[0]==0xe1,"dead-key namespace");
    in[0]='a';in[1]='e';
    need(compose_locale_lookup(0,2,in,out)==0&&compose_locale_prefix(0,2,in)==1,"short prefix removed");
    need(compose_locale_import_xcompose(src)==0&&stat(pack,&st)==0,"refused overwrite");
    snprintf(sym,sizeof(sym),"%s/symlink.XCompose",home);
    need(symlink(src,sym)==0,"make symlink");need(compose_locale_import_xcompose(sym)==0,"symlink source refused");
    snprintf(inc,sizeof(inc),"%s/include.XCompose",home);
    write_text(inc,"include \"%L\"\n<Multi_key> <a> <b> : \"x\"\n");
    need(compose_locale_import_xcompose(inc)==0,"include did not fail closed");
    need(compose_locale_remove_pack("nekoedit-test.UTF-8")==1,"remove imported pack");
    unlink(sym);unlink(src);unlink(inc);
    need(rmdir(loc)==0&&rmdir(app)==0&&rmdir(home)==0,"cleanup");
    puts("Native in-app XCompose import tests passed");
    return 0;
}
