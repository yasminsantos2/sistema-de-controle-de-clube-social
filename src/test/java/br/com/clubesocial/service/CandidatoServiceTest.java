package br.com.clubesocial.service;

import br.com.clubesocial.model.Candidato;
import br.com.clubesocial.model.CandidatoStatus;
import br.com.clubesocial.repository.CandidatoRepository;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.time.LocalDate;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class CandidatoServiceTest {

    @Mock
    private CandidatoRepository repository;

    @InjectMocks
    private CandidatoService service;

    @Test
    @DisplayName("Deve salvar um candidato com sucesso")
    void deveSalvarCandidato() {
        Candidato candidato = new Candidato("Teste", "12345678901", "teste@email.com", LocalDate.of(1990, 1, 1));
        
        when(repository.findByCpf("12345678901")).thenReturn(Optional.empty());
        when(repository.save(any(Candidato.class))).thenReturn(candidato);

        Candidato salvo = service.salvar(candidato);

        assertNotNull(salvo);
        assertEquals("Teste", salvo.getNome());
        verify(repository, times(1)).save(candidato);
    }

    @Test
    @DisplayName("Deve lançar exceção ao salvar CPF duplicado")
    void deveLancarExcecaoCpfDuplicado() {
        Candidato candidato = new Candidato("Teste", "12345678901", "teste@email.com", LocalDate.of(1990, 1, 1));
        
        when(repository.findByCpf("12345678901")).thenReturn(Optional.of(candidato));

        Exception exception = assertThrows(RuntimeException.class, () -> service.salvar(candidato));
        
        assertEquals("Já existe um candidato com este CPF.", exception.getMessage());
        verify(repository, never()).save(any());
    }

    @Test
    @DisplayName("Deve listar todos os candidatos")
    void deveListarTodos() {
        when(repository.findAll()).thenReturn(java.util.List.of(new Candidato(), new Candidato()));
        
        java.util.List<Candidato> lista = service.listarTodos();
        
        assertEquals(2, lista.size());
        verify(repository, times(1)).findAll();
    }

    @Test
    @DisplayName("Deve buscar candidato por ID com sucesso")
    void deveBuscarPorId() {
        Candidato candidato = new Candidato();
        candidato.setId(1L);
        when(repository.findById(1L)).thenReturn(Optional.of(candidato));

        Candidato encontrado = service.buscarPorId(1L);

        assertNotNull(encontrado);
        assertEquals(1L, encontrado.getId());
    }

    @Test
    @DisplayName("Deve lançar exceção ao buscar ID inexistente")
    void deveLancarExcecaoIdInexistente() {
        when(repository.findById(99L)).thenReturn(Optional.empty());

        assertThrows(RuntimeException.class, () -> service.buscarPorId(99L));
    }

    @Test
    @DisplayName("Deve deletar um candidato com sucesso")
    void deveDeletarCandidato() {
        Candidato candidato = new Candidato();
        candidato.setId(1L);
        when(repository.findById(1L)).thenReturn(Optional.of(candidato));

        service.deletar(1L);

        verify(repository, times(1)).delete(candidato);
    }

    @Test
    @DisplayName("Deve alterar o status de um candidato")
    void deveAlterarStatus() {
        Candidato candidato = new Candidato();
        candidato.setId(1L);
        candidato.setStatus(CandidatoStatus.PENDENTE);

        when(repository.findById(1L)).thenReturn(Optional.of(candidato));
        when(repository.save(any(Candidato.class))).thenAnswer(invocation -> invocation.getArgument(0));

        Candidato atualizado = service.alterarStatus(1L, CandidatoStatus.APROVADO);

        assertEquals(CandidatoStatus.APROVADO, atualizado.getStatus());
    }
}
