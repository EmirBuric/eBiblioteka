using eBiblioteka.Modeli.DTOs;
using eBiblioteka.Modeli.SearchObjects;
using eBiblioteka.Modeli.UpsertRequest;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eBiblioteka.Servisi.Interfaces
{
    public interface IKnjigaServis:ICRUDServis<KnjigaDTO,KnjigaSearchObject,KnjigaInsertRequest,KnjigaUpdateRequest>
    {
        public Task Delete(int id);
        public Task SelectKnjigaDana(int id);
    }
}
